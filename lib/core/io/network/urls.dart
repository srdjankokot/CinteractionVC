class Urls{
  static String baseUrl = 'https://vc.cinteraction.com';
  // static String baseUrl = 'https://80d0-24-135-247-244.ngrok-free.app/api';

  static String loginEndpoint = '$baseUrl/api/login';
  static String registerEndpoint = '$baseUrl/api/register';
  static String socialLoginEndpoint = '$baseUrl/api/social/login';
  static String getUserDetails = '$baseUrl/api/user';
  static String meetings = '$baseUrl/api/get/all/past/meetings?paginate=10&page=';
  static String scheduledMeetings = '$baseUrl/api/get/all/scheduled/meetings?paginate=500&page=1';
  static String nextScheduledMeetings = '$baseUrl/api/get/all/scheduled/meetings?paginate=500&page=1';
  static String startCall = '$baseUrl/api/start-call';
  static String endCall = '$baseUrl/api/end-call-with-user';
  static String scheduleMeeting = '$baseUrl/api/schedule/meeting';

  static String sendMessage = '$baseUrl/call/{call_id}/message';


  static String baseIviUrl = 'https://server.institutonline.ai';
  static String IVIAccessToken = 'Bearer 15|Jsoy8PjvLXRw3Y9ggJyYRr4ylHamlWecHNKDSOVk';


  static String engagement = '$baseIviUrl/engagement/rank';
  static String sendEngagement = '$baseUrl/api/update-call-attention';
  static String dashboard = '$baseUrl/api/dashboards';


  static String restPassword = '$baseUrl/api/forgot-password';
  static String setNewPassword = '$baseUrl/api/reset-password';
}