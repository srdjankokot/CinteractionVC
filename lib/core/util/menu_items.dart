import 'package:cinteraction_vc/features/groups/ui/groups_page.dart';
import 'package:cinteraction_vc/features/users/ui/users_page.dart';
import 'package:flutter/cupertino.dart';

import '../../features/home/ui/home_tab.dart';
import '../../features/meetings/ui/meetings_page.dart';
import '../../features/profile/ui/profile_tab.dart';
import '../../features/roles/ui/roles_page.dart';
import '../navigation/route.dart';


class MenuItem {
  const MenuItem({
    required this.label,
    required this.assetName,
    required this.builder,
    this.route,
  });

  final String label;
  final String assetName;
  final WidgetBuilder builder;
  final AppRoute? route;
}


final home = MenuItem(
  route: null,
  label: 'Home',
  assetName: 'menu_home',
  builder: (context) => const HomeTab(),
);

final dashboard = MenuItem(
  route: null,
label: 'Dashboard',
  assetName: 'menu_dashboard',
builder: (context) => const Center(child: Text('Dashboard')),
);


final meetings = MenuItem(
  route: null,
  label: 'Meetings',
  assetName: 'menu_meetings',
  builder: (context) => const MeetingsPage(),
);

final insights = MenuItem(
  route: null,
  label: 'Insights',
  assetName: 'menu_insights',
  builder: (context) => const Center(child: Text('Insights')),
);

final profile = MenuItem(
  route: null,
  label: 'Profile',
  assetName: 'menu_profile',
  builder: (context) => const ProfileTab(),
);




final users = MenuItem(
 route: AppRoute.users,
  label: 'Users',
  assetName: 'menu_profile',
  builder: (context) => const UsersPage(groupId: '',),
);

final groups = MenuItem(
  route: AppRoute.groups,
  label: 'Groups',
  assetName: 'menu_groups',
  builder: (context) => const GroupsPage(),
);

final tags = MenuItem(
  route: null,
  label: 'Tags',
  assetName: 'menu_tags',
  builder: (context) => const Center(child: Text('Tags')),
);

final roles = MenuItem(
  route: AppRoute.roles,
  label: 'Roles',
  assetName: 'menu_roles',
  builder: (context) => const RolesPage(),
);

final permissions = MenuItem(
  route: null,
  label: 'Permissions',
  assetName: 'menu_permissions',
  builder: (context) => const Center(child: Text('Permissions')),
);

final settings = MenuItem(
  route: null,
  label: 'Settings',
  assetName: 'menu_settings',
  builder: (context) => const Center(child: Text('Settings')),
);


final notifications = MenuItem(
  route: null,
  label: 'Notifications',
  assetName: 'menu_notifications',
  builder: (context) => const Center(child: Text('Notifications')),
);



final mobileBottomMenu = <MenuItem>[
  home, dashboard, meetings, insights, profile
];

final mobileProfileMenu = <MenuItem>[
  users, groups, notifications, tags, roles, permissions, settings
];


final desktopMenu = <MenuItem>[
  home, dashboard, meetings, insights,  users, groups, tags, roles, permissions, settings
];


