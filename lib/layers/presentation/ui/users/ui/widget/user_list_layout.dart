import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/ui/widget/content_layout_web.dart';
import '../../../../../../core/ui/widget/mobile_screen_toolbar.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../cubit/users/users_cubit.dart';
import '../../../profile/ui/widget/user_image.dart';

class UserListLayout extends StatelessWidget {
  final List<User> users;
  const UserListLayout({super.key, required this.users});
  
  
  

  @override
  Widget build(BuildContext context) {
    if (context.isWide) {
      return ContentLayoutWeb(
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Users',
                          style: context.titleTheme.headlineLarge,
                        ),
                        Text(
                          '${users.length} Users',
                        )
                      ],
                    )),
                    ElevatedButton(
                        onPressed: () => {context.read<UsersCubit>().addUser()},
                        child: const Text('Add user'))
                  ],
                ),
              ),
              Table(columnWidths: const {
                0: FixedColumnWidth(50),
                1: FixedColumnWidth(300),
                //   3: FixedColumnWidth(209),
                //   4: FixedColumnWidth(209),
              }, children: const [
                TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF0F0F0)),
                    children: [
                      TableCell(
                          child: Padding(
                        padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                        child: Text(''),
                      )),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('Basic info'))),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('Groups'))),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text('Average Engagement')),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('Total Meetings'))),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('Onboarded'))),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text('Created date')),

                      // TableCell(
                      //     verticalAlignment: TableCellVerticalAlignment.middle,
                      //     child: imageSVGAsset('')!),
                    ])
              ]),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: const TableBorder(
                        horizontalInside: BorderSide(
                            width: 0.5,
                            color: ColorConstants.kGray5,
                            style: BorderStyle.solid)),
                    columnWidths: const {
                      0: FixedColumnWidth(50),
                      1: FixedColumnWidth(300),
                      //   3: FixedColumnWidth(209),
                      //   4: FixedColumnWidth(209),
                    },
                    children: [
                      for (var user in users)
                        TableRow(children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Checkbox(
                              value: user.checked,
                              onChanged: (bool? value) {},
                            ),
                          ),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 27, bottom: 27),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                UserImage.medium(user.imageUrl),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: context.textTheme.displaySmall,
                                      ),
                                      Text(user.email)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Center(child: Text('${user.groups}'))),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: EngagementProgress(
                                engagement: user.avgEngagement!,
                                width: double.maxFinite,
                              )),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child:
                                  Center(child: Text('${user.totalMeetings}'))),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Center(
                                  child: imageSVGAsset(user.onboarded
                                      ? 'badge_approved'
                                      : 'badge_waiting'))),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Text('${user.createdAt?.day}/${user.createdAt?.month}/${user.createdAt?.year}')),
                        ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 29,
        child: MobileToolbarScreen(
          title: 'Users',
          body: SizedBox(
            height: MediaQuery.of(context).size.height - 29,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        '${users.length} Users',
                            style: context.textTheme.bodySmall,
                      )),
                      IconButton(
                          onPressed: () => {context.read<UsersCubit>().addUser()},
                          icon: imageSVGAsset('user_plus') as Widget)
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (BuildContext context, int index) {
                          var user = users[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserImage.medium(user.imageUrl),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: context.textTheme.displaySmall,
                                        ),
                                        Text(
                                          user.email,
                                          style: context.textTheme.bodySmall,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        EngagementProgress(
                                            engagement: user.avgEngagement!,
                                            width: double.maxFinite),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
