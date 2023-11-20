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
    this.publishers = 40,
    this.audiolevelEvent = true,
    this.audioActivePackets = 100,
    this.audioLevelAverage = 25,
    this.bitrate = 128000,
    this.firFreq,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'request': this.request, 
      'room': this.room,
      'permanent': this.permanent,
      'description': this.description,
      'is_private': this.isPrivate,
      'publishers': this.publishers,
      'audiolevel_event': this.audiolevelEvent,
      'bitrate': this.bitrate
    };
    if(null != secret){
      map['secret'] = this.secret;
    }
     if(null != pin){
      map['pin'] = this.pin;
    }
    if(null != allowed){
      map['allowed'] = this.allowed;
    }
    if(null != audioActivePackets){
      map['audio_active_packets'] = this.audioActivePackets;
    }
    if(null != audioLevelAverage){
      map['audio_level_average'] = this.audioLevelAverage;
    }
    return map;
  }

  Map<String, dynamic> toMapNew() {
    Map<String, dynamic> map = {
      'request': this.request,
      'room': this.room,
      'permanent': this.permanent,
      'description': this.description,
      'is_private': this.isPrivate,
      'new_publishers': this.publishers,
      'audiolevel_event': this.audiolevelEvent,
      'new_bitrate': this.bitrate,
      'new_fir_freq': this.firFreq
    };
    if(null != secret){
      map['secret'] = this.secret;
    }
    if(null != pin){
      map['pin'] = this.pin;
    }
    if(null != allowed){
      map['allowed'] = this.allowed;
    }
    if(null != audioActivePackets){
      map['audio_active_packets'] = this.audioActivePackets;
    }
    if(null != audioLevelAverage){
      map['audio_level_average'] = this.audioLevelAverage;
    }
    return map;
  }




}