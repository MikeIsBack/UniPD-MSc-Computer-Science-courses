import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';
import 'buttons/circle_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The [RoomOption] widget defines the component used during the adding rental proposal process to manage the number of rooms present in a specif facility.
/// When you construct the [RoomOption] widget you need to specify the name of the room that you want to manage.
class RoomOption extends StatelessWidget {
  final String roomName;
  // widget state
  final int roomCounter;
  final List<int> bedCounter;
  final void Function() onRoomDecrement;
  final void Function() onRoomIncrement;
  final void Function(int bedIndex) onBedDecrement;
  final void Function(int bedIndex) onBedIncrement;

  const RoomOption(
      {super.key,
      required this.roomName,
      required this.roomCounter,
      required this.onRoomDecrement,
      required this.onRoomIncrement,
      required this.bedCounter,
      required this.onBedDecrement,
      required this.onBedIncrement});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (roomName != AppLocalizations.of(context)!.lblBeds)
              SizedBox(width: 15.w),
            Text(
              roomName,
              style: TextStyle(fontSize: 22.w, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AddRemoveButton(
                      isAddButton: false,
                      size: 30.w,
                      onPressed: onRoomDecrement),
                  SizedBox(width: 10.w),
                  Text(
                    '$roomCounter',
                    style:
                        TextStyle(fontSize: 20.w, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 10.w),
                  AddRemoveButton(
                    isAddButton: true,
                    size: 30.w,
                    onPressed: onRoomIncrement,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (roomName == AppLocalizations.of(context)!.lblBedrooms)
          ...List.generate(
            roomCounter,
            (index) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 32.w, top: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.lblBedroom(index + 1),
                          style: TextStyle(
                              fontSize: 18.w, color: ColorPalette.oxfordBlue)),
                      Divider(
                        endIndent: 20.w,
                        color: const Color.fromRGBO(78, 128, 240, 47),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.lblBeds,
                            style: TextStyle(
                                fontSize: 22.w, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          AddRemoveButton(
                              isAddButton: false,
                              size: 30.w,
                              onPressed: () {
                                onBedDecrement(index);
                              }),
                          SizedBox(width: 10.w),
                          Text(
                            '${bedCounter[index]}',
                            style: TextStyle(
                                fontSize: 20.w, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 10.w),
                          AddRemoveButton(
                              isAddButton: true,
                              size: 30.w,
                              onPressed: () {
                                onBedIncrement(index);
                              })
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
