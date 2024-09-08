import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The class [AccountPhoto] defines all the account photo components that you can find in the app. 
/// To correctly invoke an [AccountPhoto] component you need to specify two parameters:
/// - [size], the size of the component;
/// - [imageUrl], the profile image.
class AccountPhoto extends StatelessWidget {
  final double size;
  final String? imageUrl;

  const AccountPhoto({
    super.key,
    required this.size,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: (imageUrl != null) ? NetworkImage(imageUrl!) : const AssetImage('assets/images/Standard-avatar.png')
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2.r,
            blurRadius: 5.r,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
    );
  }
}
