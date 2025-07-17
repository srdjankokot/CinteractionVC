import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/users/ui/widget/delete_company_dialog.dart';
import 'package:cinteraction_vc/layers/presentation/ui/users/ui/widget/invite_users_dialog.dart';
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
                          'Company users',
                          style: context.titleTheme.headlineLarge,
                        ),
                        Text(
                          '${users.length} Users',
                        )
                      ],
                    )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              BlocProvider<CompanyCubit>.value(
                            value: getIt<CompanyCubit>(),
                            child: const InviteUsersDialog(),
                          ),
                        );
                      },
                      child: const Text('Invite users to company'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              BlocProvider<CompanyCubit>.value(
                            value: getIt<CompanyCubit>(),
                            child: const DeleteCompanyDialog(),
                          ),
                        );
                      },
                      child: const Text('Delete Company'),
                    ),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFD0D0D0),
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('')),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Basic Info',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Roles',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Created Date',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Actions',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                          const TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Text(''),
                          ),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 27, bottom: 27),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                UserImage.medium([
                                  context.getCurrentUser!.getUserImageDTO()
                                ]),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.getCurrentUser!.name,
                                        style: context.textTheme.displaySmall,
                                      ),
                                      Text(context.getCurrentUser!.email)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Center(child: Text('Admin'))),
                          // TableCell(
                          //     verticalAlignment:
                          //         TableCellVerticalAlignment.middle,
                          //     child: EngagementProgress(
                          //       engagement: user.avgEngagement!,
                          //       width: double.maxFinite,
                          //     )),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(
                                '${user.createdAt?.day}/${user.createdAt?.month}/${user.createdAt?.year}',
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Center(
                              child: TextButton(
                                child: const Text('Remove user'),
                                onPressed: () {
                                  // ovde pozovi funkciju za brisanje korisnika
                                  // context
                                  //     .read<UsersCubit>()
                                  //     .deleteUser(user.id);
                                },
                              ),
                            ),
                          ),
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
                          onPressed: () =>
                              {context.read<UsersCubit>().addUser()},
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
                                UserImage.medium([user.getUserImageDTO()]),
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
