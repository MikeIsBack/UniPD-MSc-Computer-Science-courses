import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/style/color_palette.dart';

/// The class [AdsBox] defines all the rental proposals box that you can find in the app.
/// To correctly invoke an [AdsBox] component you need to specify the following parameters:
/// - [imageUrl], one stored photo for a specific proposal;
/// - [city], facility city;
/// - [street], facility address;
/// - [price], montly price;
/// - [bookmarkButton], if specified it provides a way to save preferred ads;
/// - [onPressed], specifies the redirect to the apartment page.
class AdsBox extends StatelessWidget {
  final String? imageUrl;
  final String city;
  final String street;
  final int price;
  final BookmarkButton? bookmarkButton;
  final void Function() onPressed;

  const AdsBox(
      {super.key,
      required this.imageUrl,
      required this.city,
      required this.street,
      required this.price,
      this.bookmarkButton,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: ColorPalette.lavenderBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child:  (imageUrl != null) 
                    ? Image.network(
                      imageUrl!,
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : Image.asset('assets/images/placeholder.jpg'),
                  ),
                  if (bookmarkButton != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: bookmarkButton!,
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: '$city, €${price.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.oxfordBlue),
                          children: [
                            TextSpan(
                                text: " per month",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.oxfordBlue))
                          ]),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      street,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: ColorPalette.oxfordBlue,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'View the solution',
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: ColorPalette.oxfordBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
