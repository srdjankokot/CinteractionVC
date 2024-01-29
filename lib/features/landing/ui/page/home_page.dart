
import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:flutter/material.dart';

import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import '../../../../core/util/menu_items.dart';
import '../../../profile/ui/widget/user_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = context.isWide ? desktopMenu : mobileBottomMenu;

    final user = context.watchCurrentUser;

    final Widget body;
    final Widget? bottomNavigationBar;
    final content = tabs[_selectedIndex].builder(context);
    context.textTheme.labelSmall;

    if (context.isWide) {
      body = Row(
        children: [
          Drawer(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  for (final (index, item) in tabs.indexed)
                    Column(
                      children: [
                        Visibility(
                            visible: index == 4,
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Admin',
                                      textAlign: TextAlign.left,
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: ColorConstants.kGray3
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Stack(
                          children: [
                            Visibility(
                              visible: _selectedIndex == index,
                              child: Row(
                                children: [
                                  Container(
                                      width: 2,
                                      height: 50,
                                      color: ColorConstants.kPrimaryColor),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        height: 50,
                                        color: ColorConstants.kPrimaryColor
                                            .withOpacity(0.05)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              margin: const EdgeInsets.only(left: 20),
                              child: ListTile(
                                selected: _selectedIndex == index,
                                title: Text(item.label,
                                    style:
                                        context.textTheme.labelMedium?.copyWith(
                                      color: _selectedIndex == index
                                          ? ColorConstants.kPrimaryColor
                                          : ColorConstants.kGray2,
                                    )),
                                leading: _selectedIndex == index
                                    ? imageSVGAsset(item.assetName)?.copyWith(
                                        colorFilter: const ColorFilter.mode(
                                            ColorConstants.kPrimaryColor,
                                            BlendMode.srcIn))
                                    : imageSVGAsset(item.assetName),
                                onTap: () =>
                                    {setState(() => _selectedIndex = index)},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
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
          for (final tab in tabs)
            BottomNavigationBarItem(
              label: tab.label,
              icon: imageSVGAsset(tab.assetName) as Widget,
              activeIcon: imageSVGAsset(tab.assetName)?.copyWith(
                  colorFilter: const ColorFilter.mode(
                      ColorConstants.kPrimaryColor, BlendMode.srcIn)) as Widget,
            ),
        ],
      );
    }

    return Scaffold(
      appBar: context.isWide
          ? PreferredSize(
              preferredSize: const Size.fromHeight(97),
              child: Container(
                height: 97,
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    imageSVGAsset('original_long_logo') as Widget,
                    const Spacer(),
                    if (user != null)
                      Row(
                        children: [
                          CallButtonShape(
                              image: imageSVGAsset('menu_notifications') as Widget,
                              bgColor: ColorConstants.kGrey100,
                              onClickAction: () => {}),
                          const SizedBox(
                            width: 10,
                          ),
                          UserImage.medium(user.imageUrl),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleSmall,
                              ),
                              Text(
                                'Professor',
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              ),
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
