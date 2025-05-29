import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/staggered_layout_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/participant_video_widget_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/video_widget_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaggeredAspectGrid extends StatelessWidget {
  const StaggeredAspectGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaggeredCubit, StaggeredLayoutState>(
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          if (state.screenWidth != screenWidth ||
              state.screenHeight != screenHeight) {
            context
                .read<StaggeredCubit>()
                .onScreenSizeChanged(screenWidth, screenHeight);
          }

          var matrix = state.matrixxx;

          var index = -1;
          return Center(
            child: SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: matrix.map((row) {
                  final itemsInRow = row.length;
                  final rowCount = matrix.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((itemSize) {
                      index++;

                      final maxWidthPerItem = screenWidth / itemsInRow;
                      final maxHeightPerItem = screenHeight / rowCount;

                      final stretchedWidth = itemSize.width.clamp(0.0, maxWidthPerItem);
                      final stretchedHeight = itemSize.height.clamp(0.0, maxHeightPerItem);


                      return BlocProvider<VideoWidgetCubit>(
                        key: ValueKey(state.streams[index].id), // optional: helps Flutter optimize rebuilds
                        create: (_) => VideoWidgetCubit(stretchedWidth, stretchedHeight, state.streams[index]),
                        child: const ParticipantVideoWidgetNew(),
                      );


                      // return ParticipantVideoWidget(remoteStream: state.streams[index], height: stretchedHeight, width: stretchedWidth);

                      // return Wrap(
                      //   runSpacing: 0,
                      //   spacing: 0,
                      //   alignment: WrapAlignment.center,
                      //   children: items.map((e) {
                      //     return BlocProvider<VideoWidgetCubit>(
                      //       key: ValueKey(e.id), // optional: helps Flutter optimize rebuilds
                      //       create: (_) => VideoWidgetCubit(itemWidth, itemHeight),
                      //       child: const ParticipantVideoWidgetNew(),
                      //     );
                      //   }).toList(),
                      // );


                    }).toList(),

                  );
                }).toList(),
              ),
            ),
          );
        });
      },
      listenWhen: (previous, current) {
        if (previous.streams != current.streams) return true;
        if (previous.screenWidth != current.screenWidth) return true;
        return false;
      },
      listener: (BuildContext context, StaggeredLayoutState state) {
        // print("state changed");
      },
    );
  }
}
