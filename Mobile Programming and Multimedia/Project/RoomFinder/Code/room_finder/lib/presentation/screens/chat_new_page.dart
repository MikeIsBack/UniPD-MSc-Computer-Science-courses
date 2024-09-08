import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:room_finder/presentation/components/account_photo.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:room_finder/style/color_palette.dart';

class ChatNewPage extends StatelessWidget {
  final String receiverImageUrl;
  final String receiverName;
  final String facilityName;
  final void Function() onTap;

  const ChatNewPage({
    super.key, 
    required this.receiverImageUrl,
    required this.receiverName,
    required this.facilityName,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SecondaryTemplateScreen(
      leftHeaderWidget: DarkBackButton(onPressed: () => Navigator.pop(context)), 
      centerHeaderWidget: AccountPhoto(size: 50.w, imageUrl: receiverImageUrl), 
      content: ChatNewPageBody(
        receiverImageUrl: receiverImageUrl, 
        receiverName: receiverName, 
        facilityName: facilityName, 
        onTap: onTap
      )
    );
  } 
}

class ChatNewPageBody extends StatelessWidget {
  final String receiverImageUrl;
  final String receiverName;
  final String facilityName;
  final void Function() onTap;

  const ChatNewPageBody({
    super.key,
    required this.receiverImageUrl,
    required this.receiverName,
    required this.facilityName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 5.h),
              Text(
                receiverName,
                style: TextStyle(
                  color: ColorPalette.oxfordBlue,
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                facilityName,
                style: TextStyle(
                  color: ColorPalette.oxfordBlue,
                  fontSize: 14.w,
                ),
              ),
              SizedBox(height: 10.h),
              Divider(
                indent: 20.w,
                endIndent: 20.w,
              ),
              SizedBox(height: 10.h),
              Text(
                DateFormat('d MMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: ColorPalette.oxfordBlue,
                  fontSize: 14.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: MessageInputField(onTap: onTap),
          ),
        ],
      ),
    );
  }
}
