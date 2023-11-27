// {
// "request" : "moderate",
// "secret" : "<room secret, mandatory if configured>",
// "room" : <unique numeric ID of the room>,
// "id" : <unique numeric ID of the participant to moderate>,
// "mid" : <mid of the m-line to refer to for this moderate request>,
// "mute" : <true|false, depending on whether the media addressed by the above mid should be muted by the moderator>
// }

// {
// "videoroom" : "success",
// }

class RoomAudioMuteReq {
  String request; // moderate
  int room;
  int id;
  String mid = "1";
  bool mute;

  RoomAudioMuteReq(
{
    this.request = 'moderate',
    this.room,
    this.id,
    this.mid,
    this.mute,
  }

  );


  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'request': request,
      'room': room,
      'id': id,
      'mid': mid,
      'mute': mute,
    };

    map.removeWhere((key, value) => value == null);
    return map;
  }

}
