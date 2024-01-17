import 'package:flutter/cupertino.dart';

@immutable
sealed class ConferenceState {
  const ConferenceState();
}

class ConferenceInitial extends ConferenceState {
  const ConferenceInitial();
}