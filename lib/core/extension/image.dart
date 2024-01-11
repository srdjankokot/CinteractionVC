import 'package:flutter/cupertino.dart';

class ImageAsset extends AssetImage {
  static const String base = 'lib/assets/images/';
  final String assetImageName;
  const ImageAsset(this.assetImageName) : super(base + assetImageName);
}