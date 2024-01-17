import 'package:flutter/cupertino.dart';

import '../../features/home/home/ui/home_tab.dart';
import '../../features/home/profile/ui/widget/profile_tab.dart';

class MenuItem {
  const MenuItem({
    required this.label,
    required this.assetName,
    required this.builder,
  });

  final String label;
  final String assetName;
  final WidgetBuilder builder;
}


final home = MenuItem(
  label: 'Home',
  assetName: 'menu_home',
  builder: (context) => const HomeTab(),
);

final dashboard = MenuItem(
label: 'Dashboard',
  assetName: 'menu_dashboard',
builder: (context) => const Center(child: Text('Dashboard')),
);


final meetings = MenuItem(
  label: 'Meetings',
  assetName: 'menu_meetings',
  builder: (context) => const Center(child: Text('Meetings')),
);

final insights = MenuItem(
  label: 'Insights',
  assetName: 'menu_insights',
  builder: (context) => const Center(child: Text('Insights')),
);

final profile = MenuItem(
  label: 'Profile',
  assetName: 'menu_profile',
  builder: (context) => const ProfileTab(),
);




final users = MenuItem(
  label: 'Users',
  assetName: 'menu_profile',
  builder: (context) => const Center(child: Text('Users')),
);

final groups = MenuItem(
  label: 'Groups',
  assetName: 'menu_groups',
  builder: (context) => const Center(child: Text('Groups')),
);

final tags = MenuItem(
  label: 'Tags',
  assetName: 'menu_tags',
  builder: (context) => const Center(child: Text('Tags')),
);

final roles = MenuItem(
  label: 'Roles',
  assetName: 'menu_roles',
  builder: (context) => const Center(child: Text('Roles')),
);

final permissions = MenuItem(
  label: 'Permissions',
  assetName: 'menu_permissions',
  builder: (context) => const Center(child: Text('Permissions')),
);

final settings = MenuItem(
  label: 'Settings',
  assetName: 'menu_settings',
  builder: (context) => const Center(child: Text('Settings')),
);


final notifications = MenuItem(
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


