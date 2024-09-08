import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/style/color_palette.dart';

/// Create a filter panel implementing the [BaseModalPanel] abstract class.
/// The filter panel contains a [panelTitle] and a list of [items].
class BaseModalPanel extends StatelessWidget {
  final String title;
  final String btnLabel;
  final void Function()? onBtnPressed;
  final void Function() onBtnClosed;
  final Widget items;

  const BaseModalPanel(
      {super.key,
      required this.title,
      required this.btnLabel,
      required this.onBtnPressed,
      required this.onBtnClosed,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          PanelTitle(
            title: title,
            onBtnClosed: onBtnClosed,
          ),
          SizedBox(height: 10.h),
          const Divider(
            thickness: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: items,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: RectangleButton(label: btnLabel, onPressed: onBtnPressed),
          )
        ],
      ),
    );
  }
}

/// Show the filter panel.
///
/// The [panel] is the panel to be shown.
///
/// The [context] is the context of the app.
Future showModalPanel(
    {required BuildContext context,
    required Widget panel,
    bool isScrollControlled = true}) {
  return showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: isScrollControlled,
      context: context,
      backgroundColor: ColorPalette.lavenderBlue,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return panel;
        });
      });
}

/// Create a [title] for the filter panel.
class PanelTitle extends StatelessWidget {
  final String title;
  final void Function() onBtnClosed;

  const PanelTitle({super.key, required this.title, required this.onBtnClosed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onBtnClosed, icon: const Icon(Icons.close)),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(onPressed: null, icon: Icon(Icons.close))),
      ],
    );
  }
}

/// Create a filter item implementing the [PanelItem] abstract class.
/// The filter item requires a [itemTitle] and an optional [itemDesc].
/// The [content] is the main content of the filter item.
abstract class PanelItem extends StatelessWidget {
  final String itemTitle;
  final String? itemDesc;

  const PanelItem({
    super.key,
    // ignore: unused_element
    required this.itemTitle,
    this.itemDesc = '',
  });

  Widget get content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 26.w),
            child: RichText(
              text: TextSpan(
                text: itemTitle,
                style: Theme.of(context).textTheme.displaySmall,
                children: [
                  TextSpan(
                    text: '\n$itemDesc',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        content,
        SizedBox(height: 20.h),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
