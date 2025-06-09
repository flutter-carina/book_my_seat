import 'package:book_my_seat/src/model/seat_layout_state_model.dart';
import 'package:book_my_seat/src/model/seat_model.dart';
import 'package:book_my_seat/src/utils/seat_state.dart';
import 'package:book_my_seat/src/widgets/seat_widget.dart';
import 'package:flutter/material.dart';
import '../model/plan_model.dart';

class SeatLayoutWidget extends StatefulWidget {
  final SeatLayoutStateModel stateModel;
  final List<Plan> plans;
  final void Function(int rowI, int colI, SeatState currentState)
      onSeatStateChanged;

  const SeatLayoutWidget({
    Key? key,
    required this.stateModel,
    required this.onSeatStateChanged,
    required this.plans,
  }) : super(key: key);

  @override
  State<SeatLayoutWidget> createState() => _SeatLayoutWidgetState();
}

class _SeatLayoutWidgetState extends State<SeatLayoutWidget> {
  final TransformationController _transformationController =
      TransformationController(Matrix4.identity()..scale(2.0));
  Map<int, String> get rowLabelMap {
    return computeRowLabels(widget.stateModel.currentSeatsState);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: double.infinity,
      child: InteractiveViewer(
        maxScale: 5,
        minScale: 0.8,
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(8),
        constrained: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.stateModel.rows, (rowI) {
            int seatNumber = 0;
            final hasVisibleSeat = widget.stateModel.currentSeatsState[rowI]
                .any((seat) => seat != SeatState.empty);

            Plan? matchingPlan;
            for (var plan in widget.plans) {
              if (plan.startRow == rowI) {
                matchingPlan = plan;
                break;
              }
            }

            return Column(
              children: [
                if (matchingPlan != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            matchingPlan.label,
                            style: const TextStyle(
                              fontSize: 7,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: 20,
                        height: widget.stateModel.seatSvgSize.toDouble(),
                        alignment: Alignment.center,
                        child: hasVisibleSeat
                            ? Text(
                                rowLabelMap[rowI] ?? '',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),

                    // Seat widgets in this row
                    ...List.generate(widget.stateModel.cols, (colI) {
                      final seatState =
                          widget.stateModel.currentSeatsState[rowI][colI];
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(0.5),
                            child: SeatWidget(
                              model: SeatModel(
                                seatState: seatState,
                                rowI: rowI,
                                colI: colI,
                                seatSvgSize: widget.stateModel.seatSvgSize,
                                pathSelectedSeat:
                                    widget.stateModel.pathSelectedSeat,
                                pathDisabledSeat:
                                    widget.stateModel.pathDisabledSeat,
                                pathSoldSeat: widget.stateModel.pathSoldSeat,
                                pathUnSelectedSeat:
                                    widget.stateModel.pathUnSelectedSeat,
                              ),
                              rowLabelMap: rowLabelMap,
                              onSeatStateChanged: widget.onSeatStateChanged,
                              seatNumber: seatState != SeatState.empty
                                  ? (++seatNumber)
                                  : null,
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Map<int, String> computeRowLabels(List<List<SeatState>> seatGrid) {
    int labelCounter = 0;
    Map<int, String> rowLabelMap = {};

    for (int i = 0; i < seatGrid.length; i++) {
      final row = seatGrid[i];
      final hasVisibleSeat = row.any((seat) => seat != SeatState.empty);
      if (hasVisibleSeat) {
        rowLabelMap[i] = getAlphabeticRowLabel(labelCounter++);
      }
    }

    return rowLabelMap;
  }

  String getAlphabeticRowLabel(int index) {
    String label = '';
    index++;
    while (index > 0) {
      index--;
      label = String.fromCharCode(65 + (index % 26)) + label;
      index ~/= 26;
    }
    return label;
  }
}
