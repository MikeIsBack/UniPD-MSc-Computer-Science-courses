import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 10.h),
          Text(
            AppLocalizations.of(context)!.lblLoading,
            style: TextStyle(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
