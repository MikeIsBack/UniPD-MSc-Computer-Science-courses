import 'package:flutter/material.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';

class AddOn extends StatelessWidget {
  final String label;
  final void Function()? onPressed;

  const AddOn({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        AddRemoveButton(isAddButton: true, size: 30, onPressed: onPressed),
      ],
    );
  }
}
