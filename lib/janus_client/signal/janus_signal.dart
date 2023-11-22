import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:random_string/random_string.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../operation/janus_handle.dart';
import '../operation/janus_transaction.dart';

/// 1.客户端发送create创建一个Janus会话；
/// 2.Janus回复success返回Janus会话句柄；
/// 3.--客户端发送attach命令在Janus会话上attach指定插件；
/// 4.--Janus回复success返回插件的句柄；
/// 5.客户端给指定的插件发送message进行信令控制；
/// 6.Janus上的插件发送event通知事件给客户端；
/// 7.客户端收集candidate并通过trickle消息发送给插件绑定的ICE通道；
/// 8.Janus发送webrtcup通知ICE通道建立；
/// 9.客户端发送媒体数据；
/// 10.Janus发送media消息通知媒体数据的第一次到达；
/// 11.Janus进行媒体数据转发。

/// 1.websocket创建连接，keepAlive,预留处理回调信息handlemessage
/// 2.创建会话create，发送janus create，success接收数据
/// 3.attach关联插件
/// 4.attach关联成功，加入房间joinroom
/// 5.创建offer(janus = message)  onPublisherJoined
/// 6.创建answer（janus = message）subscriberHandleRemoteJsep
/// 7.发送ice，trickle
///

typedef OnMessage = void Function(JanusHandle handle, Map plugin, Map jsep, JanusHandle feedHandle);

typedef ChangeDisplay = void Function(int feedId, String display);

typedef EndMeeting = void Function();

typedef NotifyTalking = void Function(int feedId);

/// janus signaling processing
class JanusSignal {
  bool disConnected = false;

  final String _kJanus = 'janus';

  int _sessionId = -1;

  int _handleId = -1;

  int _roomId;

  // websocket服务器地址
  String _url;

  // websocket服务器密钥
  String _apiSecret;

  // websocket服务器通讯token
  String _token;

  // 是否需要使用
  bool _withCredentials = false;

  // websocket information callback processing
  OnMessage _onMessage;

  ChangeDisplay _changeDisplay;

  EndMeeting _endMeeting;

  NotifyTalking _notifyTalking;

  // websocket channel
  WebSocketChannel _channel;

  Stream<dynamic> _stream;

  WebSocketSink _sink;

  // Show nickname
  String _display = 'janus';

  // keepalive time
  int _refreshInterval = 20;

  // janus transaction collection
  final Map<dynamic, JanusTransaction> _transMap = <dynamic, JanusTransaction>{};

  // janus handle collection
  final Map<dynamic, JanusHandle> _handleMap = <dynamic, JanusHandle>{};

  // janus remote stream collection
  final Map<dynamic, JanusHandle> _feedMap = <dynamic, JanusHandle>{};

  final JsonEncoder _encoder = const JsonEncoder();

  final JsonDecoder _decoder = const JsonDecoder();

  get handleId => _handleId; // self handleId

  get sessionId => _sessionId; // self session

  get handleMap => _handleMap; // self session

  set sessionId(int sessionId) => _sessionId = sessionId;

  set roomId(int roomId) => _roomId = roomId;

  set url(String url) => _url = url;

  set apiSecret(String apiSecret) => _apiSecret = apiSecret;

  set token(String token) => _token = token;

  set withCredentials(bool withCredentials) =>
      _withCredentials = withCredentials;

  set onMessage(OnMessage onMessage) => _onMessage = onMessage;

  set changeDisplay(ChangeDisplay changeDisplay) =>
      _changeDisplay = changeDisplay;

  set endMeeting(EndMeeting endMeeting) => _endMeeting = endMeeting;

  set notifyTalking(NotifyTalking notifyTalking) =>
      _notifyTalking = notifyTalking;

  set display(String display) => _display = display;

  set refreshInterval(int refreshInterval) =>
      _refreshInterval = refreshInterval;

  dynamic get _apiMap => _withCredentials
      ? _apiSecret != null
          ? {"apisecret": _apiSecret}
          : {}
      : {};

  dynamic get _tokenMap => _withCredentials
      ? _token != null
          ? {"token": _token}
          : {}
      : {};

  JanusSignal._();

  Timer keepApliveTimer;

  static JanusSignal _instance;

  /// Singleton
  static JanusSignal getInstance({
    @required String url,
    String apiSecret,
    String token,
    bool withCredentials,
    String display,
    int refreshInterval = 20,
    disConnected = false,
  }) {
    _instance ??= JanusSignal._();
    if (url != null) _instance.url = url;
    if (apiSecret != null) _instance.apiSecret = apiSecret;
    if (token != null) _instance.token = token;
    if (withCredentials != null) _instance.withCredentials = withCredentials;
    if (display != null) _instance.display = display;
    if (refreshInterval != null) _instance.refreshInterval = refreshInterval;
    if (disConnected != null) _instance.disConnected = disConnected;
    return _instance;
  }

  /// Signaling to get a connection
  void connect() {
    debugPrint('janus connect===========>${_url}');
    Iterable<String> it = ['janus-protocol'];
    _channel = WebSocketChannel.connect(Uri.parse(_url), protocols: it);
    _sink = _channel.sink;
    // this._stream = this._channel.stream.asBroadcastStream();
    _stream = _channel.stream;
    _stream.listen((message) {
      debugPrint('$_kJanus receieve: $message');
      if (null != message) {
        handleMessage(_decoder.convert(message));
      }
    }).onDone(() {
      print('closed　by server');
    });
  }

  /// websocket disconnect
  void disconnect() {
    debugPrint('janus disconnect===========>$disConnected');
    keepApliveTimer?.cancel();
    _sink.close();
    disConnected = true;
  }

  /// Send message to janus
  void sendMessage(
      {@required int handleId,
      @required Map body,
      Map jsep,
      String transaction}) {
    transaction ??= randomAlphaNumeric(12);
    Map<String, dynamic> msgMap = {
      "janus": "message",
      "body": body,
      "transaction": transaction,
      "session_id": _sessionId,
      "handle_id": handleId
    };
    if (jsep != null) {
      msgMap["jsep"] = jsep;
    }
    send(msgMap);
  }

  /// Public messaging
  void send(Map map) {
    debugPrint('janus disconnect====send=======>$disConnected');
    if (disConnected) {
      return;
    }
    debugPrint('janus client send=====>>>>>>$map');
    String json = _encoder.convert(map);
    _sink.add(json);
  }

  /// Create session
  void createSession(
      {@required TransactionSuccess success,
      @required TransactionError error}) {
    String transaction = randomAlphaNumeric(12);
    JanusTransaction jt = JanusTransaction(tid: transaction);

    jt.success = (Map data) {
      debugPrint('createSession seuccess');
      sessionId = data['data']['id'];
      keepAlive();
      success(data);
    };
    jt.error = error;

    _transMap[transaction] = jt;
    Map<String, dynamic> createMap = {
      'janus': 'create',
      'transaction': transaction,
      ..._apiMap,
      ..._tokenMap,
    };
    send(createMap);
  }

  /// attach associated janus plug-in
  void attach({
    @required String plugin,
    @required String opaqueId,
    @required TransactionSuccess success,
    @required TransactionError error,
  }) {
    String transaction = randomAlphaNumeric(12);
    JanusTransaction jt = JanusTransaction(tid: transaction);

    jt.success = (data) {_handleId = data['data']['id'];
      debugPrint('janus attach success=====data: $data======>handleId: ${_handleId}');
      _handleMap[_handleId] = JanusHandle(handleId: _handleId);
      success(data);
    };
    jt.error = error;
    _transMap[transaction] = jt;

    Map<String, dynamic> attachMap = {
      "janus": "attach",
      "plugin": plugin,
      "transaction": transaction,
      "session_id": _sessionId,
      "opaque_id": opaqueId
    };
    send(attachMap);
  }

  ///　join room
  void joinRoom({
    @required Map<String, dynamic> data,
    @required Map<String, dynamic> body,
    String display,
    int feedId,
    OnJoined onJoined,
    OnRemoteJsep onRemoteJsep,
    OnLeaving onLeaving,
    OnKicked onKicked,
  }) {
    dynamic senderSessionId = data['data']['id']; // sessionId
    JanusHandle handle =
        _handleMap[senderSessionId] ?? JanusHandle(handleId: senderSessionId);
    handle.onJoined = onJoined;
    handle.onRemoteJsep = onRemoteJsep;
    handle.onLeaving = onLeaving;
    handle.onKicked = onKicked;
    handle.display = display ?? _display;

    // Set the session_id of the handle, either the remote session_id or your own session_id
    if (feedId != null) {
      handle.feedId = feedId;
      _feedMap[feedId] = handle;
    } else {
      handle.feedId = sessionId;
    }

    _handleMap[handle.handleId] = handle;
    sendMessage(body: body, handleId: handle.handleId);
  }

  ///　Send ice to janus
  void trickleCandidate({
    @required int handleId,
    @required Map<String, dynamic> candidate,
  }) {
    Map trickleMap = {
      "janus": "trickle",
      "candidate": candidate,
      "transaction": randomNumeric(12),
      "session_id": _sessionId,
      "handle_id": handleId,
    };
    send(trickleMap);
  }

  /// heartbeat
  void keepAlive() {
    Map<String, dynamic> aliveMap = {
      'janus': 'keepalive',
      'session_id': _sessionId,
      ..._apiMap,
      ..._tokenMap,
    };
    keepApliveTimer = Timer.periodic(Duration(seconds: _refreshInterval), (timer) {
      aliveMap['transaction'] = randomNumeric(12);
      send(aliveMap);
    });
  }

  /// Processing the message returned by the janus server
  void handleMessage(Map<dynamic, dynamic> message) {
    String janus = message[_kJanus];
    debugPrint('$_kJanus handleMessage $janus');
    switch (janus) {
      case 'success':
        {
          String transaction = message['transaction'];
          JanusTransaction jt = _transMap[transaction];
          if (null != jt && jt.success != null) {
            jt.success(message);
          }
          _transMap.remove(transaction);
        }
        break;

      case 'error':
        {
          String transaction = message['transaction'];
          JanusTransaction jt = _transMap[transaction];
          if (null != jt && jt.error != null) {
            jt.error(message);
          }
          _transMap.remove(transaction);
        }
        break;

      case 'ack':
        {}
        break;

      case 'event':
        {
          Map<String, dynamic> plugin = message['plugindata']['data'];

          if (plugin['videoroom'] == 'talking' && null != _notifyTalking) {
            _notifyTalking(plugin['id']);
            return;
          }

          if (plugin['videoroom'] == 'destroyed' && null != _endMeeting) {
            _endMeeting();
            return;
          }

          if (null != _handleMap[plugin['id']] &&
              null != plugin['id'] &&
              null != plugin['display'] &&
              null != _changeDisplay) {
            _handleMap[plugin['id']].display = plugin['display'];
            _changeDisplay(plugin['id'], plugin['display']);
          }

          // Room creation successful, execution method failed
          String transaction = message['transaction'];
          JanusTransaction jt = _transMap[transaction];
          if (null != plugin && null != jt) {
            if (null != plugin['error']) {
              debugPrint('$_kJanus handleMessage event error====>: ${plugin['error']}');
              jt.error(plugin);
            } else {
              jt?.success(plugin);
            }
            _transMap.remove(transaction);
          }

          JanusHandle handle = _handleMap[message['sender']];

          JanusHandle feedHandle;
          if (plugin['leaving'] != null || plugin['kicked'] != null) {
            // someone left
            if (plugin['leaving'] != null && null == plugin['reason']) {
              // someone left
              feedHandle = _feedMap[plugin['leaving']];
            }
            if (plugin['kicked'] != null && null == plugin['reason']) {
              // someone was kicked
              feedHandle = _feedMap[plugin['kicked']];
            }
            if (plugin['leaving'] != null && null != plugin['reason']) {
              // Get kicked yourself
              feedHandle = handleMap[sessionId];
            }
          }
          _onMessage(handle, plugin, message["jsep"], feedHandle);

          if (plugin['leaving'] != null && null == plugin['reason']) {
            // 有人离开,移除handle
            // this._feedMap.remove(plugin['leaving']);
            // this._handleMap.remove(message['sender']);
            _feedMap.remove(feedHandle.feedId);
            _handleMap.remove(feedHandle.handleId);
          }

          if (plugin['kicked'] != null && null == plugin['reason']) {
            // 将某人踢掉,移除handle
            // this._feedMap.remove(plugin['kicked']);
            // this._handleMap.remove(message['sender']);
            _feedMap.remove(feedHandle.feedId);
            _handleMap.remove(feedHandle.handleId);
          }
        }
        break;

      case 'detached':
        {
          // 插件从Janus会话detach的通知，释放了一个插件句柄
          debugPrint('$_kJanus handleMessage detached: $message');
          JanusHandle handle = _handleMap[message['sender']];
          handle?.onLeaving(handle);
        }
        break;

      default:
        {
          debugPrint('$_kJanus handleMessage defalut: $message');
          JanusHandle handle = _handleMap[message['sender']];
          if (handle == null) {
            print('missing handle');
          }
        }
    }
  }

  /// Logic such as room creation and destruction
  void videoRoomHandle(
      {@required Map<String, dynamic> req,
      @required TransactionSuccess success,
      @required TransactionError error}) {
    JanusHandle handle = _handleMap[_handleId];
    String transaction = randomAlphaNumeric(12);
    JanusTransaction jt = JanusTransaction(tid: transaction);
    jt.success = success;
    jt.error = error;
    _transMap[transaction] = jt;
    sendMessage(handleId: handle.handleId, body: req, transaction: transaction);
  }

}
