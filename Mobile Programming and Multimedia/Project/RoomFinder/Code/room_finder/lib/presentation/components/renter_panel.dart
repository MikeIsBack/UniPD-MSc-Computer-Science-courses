import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:room_finder/presentation/components/base_panel.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RenterPanel extends StatelessWidget {
  final BuildContext context;

  final String title;
  final String btnLabel;
  final void Function()? onConfirmPressed;
  final void Function() onClosedPressed;

  final TextEditingController nameController;
  final TextEditingController studiesController;
  final TextEditingController interestsController;
  final TextEditingController ageController;

  final DateTime selectedDate;
  final Function(DateTime? selectedDate) onDateChanged;

  const RenterPanel({
    super.key,
    required this.context,
    required this.title,
    required this.btnLabel,
    required this.onConfirmPressed,
    required this.nameController,
    required this.studiesController,
    required this.interestsController,
    required this.onClosedPressed,
    required this.selectedDate,
    required this.onDateChanged,
    required this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    return BaseModalPanel(
        title: title,
        btnLabel: btnLabel,
        onBtnPressed: onConfirmPressed,
        onBtnClosed: onClosedPressed,
        items: Column(
        children: [
          _InputFieldItem(
            itemTitle: AppLocalizations.of(context)!.lblRenterName,
            hint: AppLocalizations.of(context)!.lblEnterName,
            controller: nameController,
          ),
          _InputFieldItem(
            itemTitle: AppLocalizations.of(context)!.lblRenterAge,
            hint: AppLocalizations.of(context)!.lblEnterAge,
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
          _InputFieldItem(
            itemTitle: AppLocalizations.of(context)!.lblStudies,
            hint: AppLocalizations.of(context)!.lblEnterStudies,
            controller: studiesController,
          ),
          _InputFieldItem(
            itemTitle: AppLocalizations.of(context)!.lblInterests,
            hint: AppLocalizations.of(context)!.lblEnterInterests,
            controller: interestsController,
          ),
          _DatePickerItem(
            itemTitle: AppLocalizations.of(context)!.lblContractDeadline,
            selectedDate: selectedDate,
            onDateChanged: onDateChanged,
          )
        ],
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField(
      {required this.hint,
      required this.controller,
      required this.keyboardType});

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.aliceBlue,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
            ),
            keyboardType: widget.keyboardType,
          ),
        ),
      ),
    );
  }
}

class _InputFieldItem extends PanelItem {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputFieldItem({
    required super.itemTitle,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget get content => _InputField(
        hint: hint,
        controller: controller,
        keyboardType: keyboardType,
      );
}

// ignore: must_be_immutable
class _DatePicker extends StatefulWidget {
  DateTime selectedDate;
  final Function(DateTime? selectedDate) onDateChanged;

  _DatePicker({required this.selectedDate, required this.onDateChanged});

  @override
  State<_DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ElevatedButton.icon(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: widget.selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2100),
                ).then((DateTime? value) {
                  if (value != null) {
                    setState(() {
                      widget.selectedDate = value;
                      widget.onDateChanged(widget.selectedDate);
                    });
                  }
                });
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_dateFormat.format(widget.selectedDate)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerItem extends PanelItem {
  final DateTime selectedDate;
  final Function(DateTime? selectedDate) onDateChanged;

  const _DatePickerItem(
      {required super.itemTitle,
      required this.selectedDate,
      required this.onDateChanged});

  @override
  Widget get content => _DatePicker(
        selectedDate: selectedDate,
        onDateChanged: onDateChanged,
      );
}
