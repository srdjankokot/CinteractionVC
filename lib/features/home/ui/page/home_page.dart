import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/features/login_page/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../profile/ui/widget/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _tabs = <_HomeTab>[
    _HomeTab(
      label: 'Home',
      icon: Image.asset(
        "lib/assets/images/bottom_menu/menu_home.png",
        fit: BoxFit.scaleDown,
      ),
      activeIcon: Image.asset(
        "lib/assets/images/bottom_menu/menu_home_active.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context) => const Center(child: Text('Home')),
    ),
    _HomeTab(
      label: 'Dashboard',
      icon: Image.asset(
        "lib/assets/images/bottom_menu/menu_dashboard.png",
        fit: BoxFit.scaleDown,
      ),
      activeIcon: Image.asset(
        "lib/assets/images/bottom_menu/menu_home_active.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context) => const Center(child: Text('Dashboard')),
    ),
    _HomeTab(
      label: 'Meetings',
      icon: Image.asset(
        "lib/assets/images/bottom_menu/menu_meetings.png",
        fit: BoxFit.scaleDown,
      ),
      activeIcon: Image.asset(
        "lib/assets/images/bottom_menu/menu_meetings_active.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context) => const Center(child: Text('Meetings')),
    ),
    _HomeTab(
      label: 'Insights',
      icon: Image.asset(
        "lib/assets/images/bottom_menu/menu_insights.png",
        fit: BoxFit.scaleDown,
      ),
      activeIcon: Image.asset(
        "lib/assets/images/bottom_menu/menu_insights_active.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context) => const Center(child: Text('Insights')),
    ),
    _HomeTab(
      label: 'Profile',
      icon: Image.asset(
        "lib/assets/images/bottom_menu/menu_profile.png",
        fit: BoxFit.scaleDown,
      ),
      activeIcon: Image.asset(
        "lib/assets/images/bottom_menu/menu_profile_active.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context) => const ProfileTab()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget body;
    final Widget? bottomNavigationBar;
    final content = _tabs[_selectedIndex].builder(context);

    if (context.isWide) {
      body = Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: [
              for (final tab in _tabs)
                NavigationRailDestination(
                  label: Text(tab.label),
                  icon: tab.icon,
                ),
            ],
          ),
          Expanded(child: content),
        ],
      );
      bottomNavigationBar = null;
    } else {
      body = SafeArea(child: content);
      bottomNavigationBar = BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
                label: tab.label, icon: tab.icon, activeIcon: tab.activeIcon),
        ],
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _HomeTab {
  const _HomeTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.builder,
  });

  final String label;
  final Image icon;
  final Image activeIcon;
  final WidgetBuilder builder;
}
