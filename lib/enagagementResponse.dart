class EngagementResponse {
  List<Engagement> engagements;

  EngagementResponse(this.engagements);

  EngagementResponse.fromJson(Map json) : engagements = json['engagements'];
}

class Engagement {
  int call_id;
  int participant_id;
  double engagement_rank;

  Engagement(this.call_id, this.participant_id, this.engagement_rank);

  Engagement.fromJson(Map json) :
        call_id = json['call_id'],
        participant_id = json['participant_id'],
        engagement_rank = json['engagement_rank'];
}
