// {
//         "request" : "create",
//         "room" : <unique numeric ID, optional, chosen by plugin if missing>,
//         "permanent" : <true|false, whether the room should be saved in the config file, default=false>,
//         "description" : "<pretty name of the room, optional>",
//         "secret" : "<password required to edit/destroy the room, optional>",
//         "pin" : "<password required to join the room, optional>",
//         "is_private" : <true|false, whether the room should appear in a list request>,
//         "allowed" : [ array of string tokens users can use to join this room, optional],
//         ...
// }

//https://janus.conf.meetecho.com/docs/videoroom.html

import 'package:flutter/cupertino.dart';

enum RoomAction {
  create, destroy, edit , exists, list, allowed, kick, listparticipants
}

class RoomReq {

  String request;     // create, destroy, edit , exists, list, allowed, kick

  int room;

  bool permanent;

  String description;

  String secret;

  String pin;

  bool isPrivate;

  List<dynamic> allowed;

  int publishers;

  bool audiolevelEvent;

  int audioActivePackets;

  int audioLevelAverage;
  int bitrate;
  int firFreq;


  RoomReq({
    @required this.request, 
    @required this.room, 
    this.permanent = false, 
    this.description = "",
    this.secret, 
    this.pin, 
    this.isPrivate = false, 
    this.allowed,
    this.publishers = 100,
    this.audiolevelEvent = true,
    this.audioActivePackets = 100,
    this.audioLevelAverage = 25,
    this.bitrate = 128000,
    this.firFreq = 10,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'request': request,
      'room': room,
      'permanent': permanent,
      'description': description,
      'is_private': isPrivate,
      'publishers': publishers,
      'audiolevel_event': audiolevelEvent,
    };
    if(null != secret){
      map['secret'] = secret;
    }
     if(null != pin){
      map['pin'] = pin;
    }
    if(null != allowed){
      map['allowed'] = allowed;
    }
    if(null != audioActivePackets){
      map['audio_active_packets'] = audioActivePackets;
    }
    if(null != audioLevelAverage){
      map['audio_level_average'] = audioLevelAverage;
    }
    return map;
  }

  Map<String, dynamic> toMapNew() {
    Map<String, dynamic> map = {
      'request': request,
      'room': room,
      'permanent': permanent,
      'description': description,
      'is_private': isPrivate,
      'new_publishers': publishers,
      'audiolevel_event': audiolevelEvent,
      'new_bitrate': bitrate,
      'new_fir_freq': firFreq
    };
    if(null != secret){
      map['secret'] = secret;
    }
    if(null != pin){
      map['pin'] = pin;
    }
    if(null != allowed){
      map['allowed'] = allowed;
    }
    if(null != audioActivePackets){
      map['audio_active_packets'] = audioActivePackets;
    }
    if(null != audioLevelAverage){
      map['audio_level_average'] = audioLevelAverage;
    }
    return map;
  }




}