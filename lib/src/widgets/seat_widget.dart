import 'package:book_my_seat/src/model/seat_model.dart';
import 'package:book_my_seat/src/utils/seat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SeatWidget extends StatefulWidget {
  final SeatModel model;
  final int? seatNumber;
  final void Function(int rowI, int colI, SeatState currentState)
      onSeatStateChanged;

  const SeatWidget({
    Key? key,
    required this.model,
    required this.onSeatStateChanged,
    this.seatNumber,
  }) : super(key: key);

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> {
  SeatState? seatState;
  int rowI = 0;
  int colI = 0;

  @override
  void initState() {
    super.initState();
    seatState = widget.model.seatState;
    rowI = widget.model.rowI;
    colI = widget.model.colI;
  }

  @override
  Widget build(BuildContext context) {
    final safeCheckedSeatState = seatState;
    if (safeCheckedSeatState != null) {
      
      return GestureDetector(
        onTapUp: (_) {
          switch (seatState) {
            case SeatState.selected:
              {
                setState(() {
                  seatState = SeatState.unselected;
                  widget.onSeatStateChanged(rowI, colI, SeatState.unselected);
                });
              }
              break;
            case SeatState.unselected:
              {
                setState(() {
                  seatState = SeatState.selected;
                  widget.onSeatStateChanged(rowI, colI, SeatState.selected);
                });
              }
              break;
            case SeatState.disabled:
            case SeatState.sold:
            case SeatState.empty:
            default:
              {}
              break;
          }
        },
        child: seatState != SeatState.empty
            ? Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    _getSvgPath(safeCheckedSeatState),
                    height: widget.model.seatSvgSize.toDouble(),
                    width: widget.model.seatSvgSize.toDouble(),
                    fit: BoxFit.cover,
                  ),
                  if (widget.seatNumber != null)
                  Text(
                    widget.seatNumber.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 5,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : SizedBox(
                height: widget.model.seatSvgSize.toDouble(),
                width: widget.model.seatSvgSize.toDouble(),
              ),
      );
    }
    return const SizedBox();
  }

  String _getSvgPath(SeatState state) {
    switch (state) {
      case SeatState.unselected:
        {
          return widget.model.pathUnSelectedSeat;
        }
      case SeatState.selected:
        {
          return widget.model.pathSelectedSeat;
        }
      case SeatState.disabled:
        {
          return widget.model.pathDisabledSeat;
        }
      case SeatState.sold:
        {
          return widget.model.pathSoldSeat;
        }
      case SeatState.empty:
      default:
        {
          return widget.model.pathDisabledSeat;
        }
    }
  }
}
