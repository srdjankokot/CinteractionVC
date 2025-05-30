class Urls {
  // static String baseUrl = 'https://vc.cinteraction.com';
  static String baseUrl = 'https://huawei.nswebdevelopment.com';
  // static String baseUrl = 'https://80d0-24-135-247-244.ngrok-free.app/api';

  static String loginEndpoint = '$baseUrl/api/login';
  static String logOutEndpoint = '$baseUrl/api/logout';
  static String registerEndpoint = '$baseUrl/api/register';
  static String socialLoginEndpoint = '$baseUrl/api/social/login';
  static String getUserDetails = '$baseUrl/api/user';
  static String meetings = '$baseUrl/api/meetings/past?paginate=10&page=';
  static String scheduledMeetings =
      '$baseUrl/api/meetings/scheduled?paginate=500&page=1';
  static String nextScheduledMeetings =
      '$baseUrl/api/meetings/scheduled?paginate=500&page=1';
  static String startCall = '$baseUrl/api/meetings/start';
  static String endCall(int callId, int userId) {
    return '$baseUrl/api/meetings/end/$callId/for/user/$userId';
  }

  static String scheduleMeeting = '$baseUrl/api/meetings/schedule';

  static String sendMessage = '$baseUrl/call/{call_id}/message';

  static String baseIviUrl = 'https://server.institutonline.ai';
  static String IVIAccessToken = 'Bearer 15|Jsoy8PjvLXRw3Y9ggJyYRr4ylHamlWecHNKDSOVk';


  static String engagement = '$baseIviUrl/engagement/rank';
  static String drowsiness = '$baseIviUrl/engagement/rank';
  static String sendEngagement = '$baseUrl/api/meetings/update/attention/';
  static String dashboard = '$baseUrl/api/dashboards';

  static String restPassword = '$baseUrl/api/forgot-password';
  static String setNewPassword = '$baseUrl/api/reset-password';
  static String sentMessage =
      'https://7a2f-188-2-51-157.ngrok-free.app/api/message';

  static String getCompanyUsers = '$baseUrl/api/users/chat';

  ////////CHAT_URLS////////
  static String getAllChats = '$baseUrl/api/chats';
  static String getChatById = '$baseUrl/api/chats/chat/';
  static String getChatByParticipiant = '$baseUrl/api/chats/user/';
  static String deleteChat = '$baseUrl/api/chats/delete/';
  static String sentChatMessage = '$baseUrl/api/chats/create';
  static String deleteMessageById = '$baseUrl/api/chats/delete/message/';
  static String editMessage = '$baseUrl/api/chats/edit/message/';
  static String removeUserFromGroupChat =
      '$baseUrl/api/chats/remove/user/from/chat/';
  static String addUserOnGroupChat = '$baseUrl/api/chats/add/user/';
  static String downloadMedia = '$baseUrl/api/chats/show/media/';
}
