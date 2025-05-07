import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DeepLinkHandler {
  static const _channel = MethodChannel('app.channel.uri');

  static void init(Function(String route) onRoute) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUri') {
        final uri = Uri.parse(call.arguments);
        final routeParam = uri.queryParameters['route'];
        if (routeParam != null) {
          onRoute(routeParam);
        } else {
          print('⚠️ No route found in URI: $uri');
        }
      }
    });
  }
}
