class Urls{
  static String baseUrl = 'https://vc.cinteraction.com/api';
  // static String baseUrl = 'https://80d0-24-135-247-244.ngrok-free.app/api';

  static String loginEndpoint = '$baseUrl/login';
  static String registerEndpoint = '$baseUrl/register';
  static String socialLoginEndpoint = '$baseUrl/social/login';
  static String getUserDetails = '$baseUrl/user';
  static String meetings = '$baseUrl/get/all/past/meetings?paginate=500&page=1';
  static String startCall = '$baseUrl/start-call';
  static String endCall = '$baseUrl/end-call-with-user';

  static String baseIviUrl = 'https://server.institutonline.ai:55611';
  static String IVIAccessToken = 'Bearer 15|Jsoy8PjvLXRw3Y9ggJyYRr4ylHamlWecHNKDSOVk';

  static String engagement = '$baseIviUrl/engagement/rank';
}