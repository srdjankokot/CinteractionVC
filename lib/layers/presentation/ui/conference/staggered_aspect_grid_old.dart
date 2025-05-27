import 'dart:math';

import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaggeredAspectGridOld extends StatelessWidget {
  final int itemCount;
  final List<double> aspectRatios;

  const StaggeredAspectGridOld({
    super.key,
    required this.itemCount,
    this.aspectRatios = const [16 / 9, 3 / 4],
  });

  bool check(int numberOfRows, int itemCount, int landScapeCount, double itemHeight, double screenWidth) {
    final double landscapeAspect = aspectRatios.first;
    final double portraitAspect = aspectRatios.length > 1 ? aspectRatios[1] : landscapeAspect;

    final itemWidthLandscape = itemHeight * landscapeAspect;
    final itemWidthPortrait = itemHeight * portraitAspect;

    final itemsPerRow = (itemCount / numberOfRows).ceil();
    final landscapePerRow = (landScapeCount / numberOfRows).ceil();
    final portraitPerRow = itemsPerRow - landscapePerRow;

    final rowWidth = landscapePerRow * itemWidthLandscape + portraitPerRow * itemWidthPortrait;
    return rowWidth > screenWidth;
  }

  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      final double landscapeAspect = aspectRatios.first;
      final double portraitAspect = aspectRatios.length > 1 ? aspectRatios[1] : landscapeAspect;

      int rows = screenWidth > screenHeight ? 3 : 4;
      int landscapeCount = itemCount;
      double itemHeight = screenHeight / rows;

      int numberOfRowsForLandscape = 1;
      while (check(numberOfRowsForLandscape, itemCount, itemCount, itemHeight, screenWidth)) {
        numberOfRowsForLandscape++;
        itemHeight = screenHeight / numberOfRowsForLandscape;
      }

      if (numberOfRowsForLandscape > rows) {
        landscapeCount = itemCount;
        itemHeight = screenHeight / rows;

        while (check(rows, itemCount, landscapeCount, itemHeight, screenWidth)) {
          landscapeCount--;
          if (landscapeCount < 0) {
            rows--;
            landscapeCount = itemCount;
            itemHeight = screenHeight / rows;
            if (rows <= 0) {
              landscapeCount = 0;
              rows = screenWidth > screenHeight ? 3 : 4;
              itemHeight = screenHeight / rows;
              break;
            }
          }
        }
      }


      final itemsPerRow = (itemCount / rows).ceil();
      final landscapePerRow = (landscapeCount / rows).ceil();
      final portraitPerRow = itemsPerRow - landscapePerRow;

      final List<bool> matrix = [];

      for (int row = 0; row < rows; row++) {
        int landscapeInCurrentRow = 0;
        int totalItemsInRow = 0;

        while (totalItemsInRow < itemsPerRow) {
          bool isLandscape = false;
          if (landscapeInCurrentRow < landscapePerRow) {
            isLandscape = Random().nextBool();
            if (isLandscape) landscapeInCurrentRow++;
          }

          if (!isLandscape && (itemsPerRow - totalItemsInRow <= (landscapePerRow - landscapeInCurrentRow))) {
            isLandscape = true;
            landscapeInCurrentRow++;
          }

          matrix.add(isLandscape);
          totalItemsInRow++;
        }
      }

      return Center(
        child: Wrap(
          spacing: 0,
          runSpacing: 0,
          alignment: WrapAlignment.center,
          children: List.generate(itemCount, (index) {
            final bool isLandscape = matrix[index];
            final double width = isLandscape ? itemHeight * landscapeAspect : itemHeight * portraitAspect;
            return SizedBox(
              width: width,
              height: itemHeight,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: context.textTheme.titleLarge!.copyWith(color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}