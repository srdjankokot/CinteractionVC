import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  splash('/'),
  home('/home'),
  meeting('/home/meeting'),
  users('/home/users/:groupId'),
  groups('/home/groups'),
  roles('/home/roles'),
  settings('/settings'),
  auth('/auth'),
  forgotPassword('/auth/forgot_password'),
  forgotPasswordSuccess('/auth/forgot_password/success'),
  ;

  const AppRoute(this.path);

  final String path;
}

extension AppRouteNavigation on AppRoute {
  void go(BuildContext context) => context.go(path);

  void push(BuildContext context) => context.push(path);
  void pushReplacement(BuildContext context) => context.pushReplacement(path);

}
