import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:cinteraction_vc/features/profile/ui/widget/user_image.dart';
import 'package:cinteraction_vc/features/roles/bloc/roles_cubit.dart';
import 'package:cinteraction_vc/features/users/ui/widget/authority_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/widget/content_layout_web.dart';
import '../../../profile/model/user.dart';
import '../../model/role.dart';

class RolesListLayout extends StatelessWidget {
  final List<Role> roles;

  const RolesListLayout({super.key, required this.roles});

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
                       Expanded(child:

                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Roles & Permissions', style: context.textTheme.headlineLarge,),
                           Text('${roles.length} Roles',)
                         ],
                       )

                       ),



                      ElevatedButton(
                          onPressed: () => {context.read<RolesCubit>().addRole()},
                          child: const Text('Add Role'))
                    ],
                  ),
                ),
                Table(
                    columnWidths: const {
                      0: FixedColumnWidth(50),
                      //   2: FixedColumnWidth(115),
                      //   3: FixedColumnWidth(209),
                      //   4: FixedColumnWidth(209),
                    },
                    children: const [
                      TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF0F0F0)),
                          children: [
                            TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('ID'),
                                )),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Name'))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Users'))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Permissions'))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Authority Level'))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Created at'))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Text('Modified')),


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
                        //   2: FixedColumnWidth(115),
                        //   3: FixedColumnWidth(209),
                        //   4: FixedColumnWidth(209),
                      },
                      children: [
                        for (var role in roles)
                          TableRow(children: [
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child:  Center(
                                child: Text(
                                  role.id,
                                ),
                              ),
                            ),
                            TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 27, bottom: 27),
                                  child: Text(
                                    role.name,
                                  ),
                                )),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text('${role.users}'))),

                            TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Center(child: Text('${role.permissions.length}'))),

                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: AuthorityLevel(level: role.authorityLevel,)),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text(
                                    '${role.createdAt.day}/${role.createdAt.month}/${role.createdAt.year}'))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Text(
                                    '${role.createdAt.day}/${role.createdAt.month}/${role.createdAt.year}')),
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
      return Container();
    }
  }
}
