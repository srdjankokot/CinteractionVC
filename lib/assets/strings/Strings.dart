

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StringKey{
  appTitle,
  title,
  enterDisplayNameTitle,
  enterRoomIdTitle,
  enterVideoRoomButton
}

class Strings{
  static String getText(StringKey key, BuildContext context){
    switch(key)
    {
      case StringKey.title:
        return AppLocalizations.of(context)!.title;
      case StringKey.enterDisplayNameTitle:
        return AppLocalizations.of(context)!.enter_display_name_title;
      case StringKey.enterRoomIdTitle:
        return AppLocalizations.of(context)!.enter_room_id_title;
      case StringKey.enterVideoRoomButton:
        return AppLocalizations.of(context)!.enter_room_button;
      case StringKey.appTitle:
        return AppLocalizations.of(context)!.app_name;
    }
  }
}

