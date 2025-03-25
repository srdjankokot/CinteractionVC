import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/core/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/ui/images/image.dart';
import '../../../../../../core/util/menu_items.dart';

import '../../../../cubit/chat/chat_cubit.dart';
import '../../../../cubit/chat/chat_state.dart';
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

    final user = context.getCurrentUser;

    final content = tabs[_selectedIndex].builder(context);

    context.textTheme.labelSmall;

    void handleClick(BuildContext context, String value) {
      switch (value) {
        case 'LogOut':
          context.logOut();
          break;
      }
    }

    final chatCubit = context.watch<ChatCubit>();

    // return BlocConsumer<ChatCubit, ChatState>(
    //   builder: (context, state) {
    final Widget body;
    final Widget? bottomNavigationBar;

    if (context.isWide) {
      body = Row(
        children: [
          Visibility(
            visible: _selectedIndex != 3,
            child: Drawer(
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
                                      child: Text('Admin',
                                          textAlign: TextAlign.left,
                                          style: context.textTheme.labelSmall
                                              ?.copyWith(
                                                  color:
                                                      ColorConstants.kGray3)),
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
                                  trailing: item.label == "Chat" &&
                                          chatCubit.state.unreadMessages > 0
                                      ? Text(chatCubit.state.unreadMessages
                                          .toString())
                                      : null,
                                  title: Text(item.label,
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () => {
                                setState(() {
                                  _selectedIndex = 0;
                                }),
                              },
                          child: imageSVGAsset('original_long_logo') as Widget),
                    ),
                    const Spacer(),
                    if (user != null)
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          UserImage.medium(user.imageUrl),
                          const SizedBox(width: 15),
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
                                'Participant',
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Tooltip(
                            message: 'LogOut',
                            child: IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: () => handleClick(context, 'LogOut'),
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            )
          : null,
      body: BlocProvider.value(
        value: context.read<ChatCubit>(), // Keep using the same ChatCubit
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
    //   },
    //   listener: (BuildContext context, ChatState state) {
    //     print(state);
    //   },
    // );
  }
}

// Child widget
class ChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
      if (state.isInitial) {
        return Text('Initial State');
      } else
        return Text('Loaded State: ${state.unreadMessages}');
    });
  }
}
