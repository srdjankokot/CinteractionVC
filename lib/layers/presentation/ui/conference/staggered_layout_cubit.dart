import 'package:equatable/equatable.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/util.dart';

class StaggeredCubit extends Cubit<StaggeredLayoutState> with BlocLoggy {
  StaggeredCubit() : super(const StaggeredLayoutState.initial()) {
    _init();
  }

  void _init() {
    setStreams([
      StreamRenderer("1", 'User 1'),
      StreamRenderer("1", 'User 2'),
      StreamRenderer("1", 'User 3'),
      StreamRenderer("1", 'User 4'),
      StreamRenderer("1", 'User 5'),
      // StreamRenderer("1", 'User 6'),
      // StreamRenderer("1", 'User 7'),
      // StreamRenderer("1", 'User 8'),
      // StreamRenderer("1", 'User 9'),
    ]);
  }

  Future<void> setStreams(List<StreamRenderer> streams) async {
    emit(state.copyWith(streams: streams));
    _calculateOptimalLayout(1);
  }

  Future<void> onScreenSizeChanged(
      double screenWidth, double screenHeight) async {
    emit(state.copyWith(screenWidth: screenWidth, screenHeight: screenHeight));
    _calculateOptimalLayout(1);

  }

  List<int> distributeItemsToRows(int itemCount, int rowCount) {
    int base = itemCount ~/ rowCount;
    int extra = itemCount % rowCount;

    return List.generate(
      rowCount,
          (index) => index < extra ? base + 1 : base,
    );
  }

  double _calculateArea(List<int> itemsPerRow) {
    final screenArea = state.screenWidth * state.screenHeight;
    final aspectRatio = state.aspectRatios.first;
    final rowCount = itemsPerRow.length;
    final maxHeightPerRow = state.screenHeight / rowCount;

    double totalArea = 0;

    for (final count in itemsPerRow) {
      final maxWidthPerItem = state.screenWidth / count;
      final widthByAspect = maxHeightPerRow * aspectRatio;
      final itemWidth = widthByAspect > maxWidthPerItem ? maxWidthPerItem : widthByAspect;

      final itemSize = _calculateItemSize(itemWidth, maxHeightPerRow, count);
      final rowArea = itemSize.width * itemSize.height * count;

      totalArea += rowArea;
    }

    return totalArea / screenArea * 100;
  }

  void _calculateOptimalLayout(int rowCount) {
    // print(rowCount);
    final currentLayout = distributeItemsToRows(state.streams.length, rowCount);
    final currentArea = _calculateArea(currentLayout);

    final nextRowCount = rowCount + 1;
    final nextLayout = distributeItemsToRows(state.streams.length, nextRowCount);
    final nextArea = _calculateArea(nextLayout);


    // print("currentArea: $currentArea");
    // print("nextArea: ${nextArea.toInt()}");

    if (nextArea > currentArea + 3  && nextArea.toInt() <= 100) {
      _calculateOptimalLayout(nextRowCount);
    } else {
      fillMatrix(currentLayout);
    }
  }

  ItemSize _calculateItemSize(double maxWidth, double maxHeight, int itemsInRow) {
    final portraitAspect = state.aspectRatios.length > 1 ? state.aspectRatios[1] : state.aspectRatios.first;

    final minWidth = maxHeight * portraitAspect;
    final maxWidthPerItem = state.screenWidth / itemsInRow;

    if (maxWidth >= minWidth && maxWidth * itemsInRow <= state.screenWidth) {
      return ItemSize(maxWidth, maxHeight);
    } else {
      final height = maxWidthPerItem / portraitAspect;
      return ItemSize(maxWidthPerItem, height);
    }
  }

  void fillMatrix(List<int> itemsPerRow) {
    final aspectRatio = state.aspectRatios.first;
    final rowCount = itemsPerRow.length;
    final maxHeightPerRow = state.screenHeight / rowCount;

    final matrix = itemsPerRow.map((count) {
      final maxWidthPerItem = state.screenWidth / count;
      final widthByAspect = maxHeightPerRow * aspectRatio;
      final itemWidth = widthByAspect > maxWidthPerItem ? maxWidthPerItem : widthByAspect;

      final itemSize = _calculateItemSize(itemWidth, maxHeightPerRow, count);
      return List<ItemSize>.filled(count, itemSize);
    }).toList();

    emit(state.copyWith(matrixxx: matrix));
  }
}

class StaggeredLayoutState extends Equatable {
  final List<StreamRenderer> streams; // numberOfStreams
  final List<double> aspectRatios;
  final List<double> finalWidths;
  final List<List<ItemSize>> matrixxx;
  final double screenWidth;
  final double screenHeight;
  final int landscapePerRow;
  final List<bool> matrix;
  final double itemHeight;

  const StaggeredLayoutState({
    required this.streams,
    required this.aspectRatios,
    required this.screenWidth,
    required this.screenHeight,
    required this.landscapePerRow,
    required this.matrix,
    required this.itemHeight,
    required this.finalWidths,
    required this.matrixxx,
  });

  const StaggeredLayoutState.initial(
      {List<StreamRenderer> streams = const [],
      List<double> aspectRatios = const [16 / 9, 3 / 4],
      List<double> finalWidths = const [],
      List<List<ItemSize>> matrixxx = const [],
      double screenWidth = 1920,
      double screenHeight = 1080,
      int landscapePerRow = 0,
      List<bool> matrix = const [],
      double itemHeight = 1080})
      : this(
          streams: streams,
          aspectRatios: aspectRatios,
          finalWidths: finalWidths,
          matrixxx: matrixxx,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          landscapePerRow: landscapePerRow,
          matrix: matrix,
          itemHeight: itemHeight,
        );

  @override
  List<Object?> get props => [
        streams,
        aspectRatios,
        screenWidth,
        screenHeight,
        landscapePerRow,
        matrix,
        itemHeight,
        finalWidths,
        matrixxx
      ];

  StaggeredLayoutState copyWith({
    List<StreamRenderer>? streams,
    List<double>? aspectRatios,
    List<double>? finalWidths,
    List<List<ItemSize>>? matrixxx,
    double? screenWidth,
    double? screenHeight,
    double? itemHeight,
    int? landscapePerRow,
    List<bool>? matrix,
  }) {
    return StaggeredLayoutState(
      streams: streams ?? this.streams,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      landscapePerRow: landscapePerRow ?? this.landscapePerRow,
      matrix: matrix ?? this.matrix,
      itemHeight: itemHeight ?? this.itemHeight,
      finalWidths: finalWidths ?? this.finalWidths,
      matrixxx: matrixxx ?? this.matrixxx,
    );
  }
}

class ItemSize {
  ItemSize(this.width, this.height);

  double width;
  double height;
}
