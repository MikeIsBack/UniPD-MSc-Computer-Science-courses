import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/components/amenities_option.dart';
import 'package:room_finder/presentation/components/base_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [SearchFilterPanel] is a filter panel that contains a list of filter items, in order to filter the search results.
///
/// The filter items are:
///
/// - Price range
///
/// - Amenities
///
/// - Bedrooms
///
/// - Beds
///
/// - Bathrooms
///
/// - Roommates
class SearchFilterPanel extends StatefulWidget {
  final BuildContext context;
  final String panelTitle;
  final String buttonLabel;

  final RangeValues currentRangeValues;
  final Map<String, bool> amenitiesSwitches;
  final Map<String, int> selectedRoomIndex;

  final void Function(RangeValues) onPriceChanged;
  final void Function(String, bool) onServiceChanged;
  final void Function(String, bool, int) onRoomIndexSelected;
  final void Function()? onConfirmPressed;
  final void Function() onClosedPressed;

  const SearchFilterPanel(
      {super.key,
      required this.context,
      required this.panelTitle,
      required this.buttonLabel,
      required this.currentRangeValues,
      required this.amenitiesSwitches,
      required this.selectedRoomIndex,
      required this.onConfirmPressed,
      required this.onClosedPressed,
      required this.onPriceChanged,
      required this.onServiceChanged,
      required this.onRoomIndexSelected});

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  @override
  Widget build(BuildContext context) {
    return BaseModalPanel(
      title: widget.panelTitle,
      btnLabel: widget.buttonLabel,
      onBtnPressed: widget.onConfirmPressed,
      onBtnClosed: widget.onClosedPressed,
      items: Column(
        children: [
          _PriceRangeItem(
            context: widget.context,
            itemTitle: AppLocalizations.of(widget.context)!.lblPriceRange,
            itemDesc: AppLocalizations.of(widget.context)!.lblPriceDesc,
            currentRangeValues: widget.currentRangeValues,
            onChanged: widget.onPriceChanged,
          ),
          _AmenitiesItem(
            itemTitle: AppLocalizations.of(widget.context)!.lblAmenities,
            amenitiesOptions: widget.amenitiesSwitches.entries
                .map((entry) => AmenitiesOption(
                      label: entry.key,
                      isChecked: entry.value,
                      onChanged: (value) {
                        widget.onServiceChanged(entry.key, value);
                      },
                    ))
                .toList(),
          ),
          _RoomsItem(
            itemTitle: AppLocalizations.of(widget.context)!.lblBedrooms,
            selectedIndex: widget.selectedRoomIndex[
                AppLocalizations.of(widget.context)!.lblBedrooms]!,
            onSelected: widget.onRoomIndexSelected,
          ),
          _RoomsItem(
            itemTitle: AppLocalizations.of(widget.context)!.lblBeds,
            selectedIndex: widget.selectedRoomIndex[
                AppLocalizations.of(widget.context)!.lblBeds]!,
            onSelected: widget.onRoomIndexSelected,
          ),
          _RoomsItem(
            itemTitle: AppLocalizations.of(widget.context)!.lblBathrooms,
            selectedIndex: widget.selectedRoomIndex[
                AppLocalizations.of(widget.context)!.lblBathrooms]!,
            onSelected: widget.onRoomIndexSelected,
          ),
          _RoomsItem(
            itemTitle: AppLocalizations.of(widget.context)!.lblRoommates,
            selectedIndex: widget.selectedRoomIndex[
                AppLocalizations.of(widget.context)!.lblRoommates]!,
            onSelected: widget.onRoomIndexSelected,
          ),
        ],
      ),
    );
  }
}

/// Create a custom range slider.
/// The range slider has a minimum value of 0 and a maximum value of <TO BE DEFINED STATICALLY/DINAMICALLY>.
class _CustomRangeSlider extends StatefulWidget {
  final RangeValues currentRangeValues;
  final void Function(RangeValues) onChanged;

  const _CustomRangeSlider(
      {required this.currentRangeValues, required this.onChanged});

  @override
  State<_CustomRangeSlider> createState() => _CustomRangeSliderState();
}

class _CustomRangeSliderState extends State<_CustomRangeSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RangeSlider(
          inactiveColor: Colors.grey,
          values: widget.currentRangeValues,
          max: 1000,
          divisions: 100,
          labels: RangeLabels(
            widget.currentRangeValues.start.round().toString(),
            widget.currentRangeValues.end.round().toString(),
          ),
          onChanged: widget.onChanged,
        ),
        Row(
          children: [
            Text(
              widget.currentRangeValues.start.round().toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              widget.currentRangeValues.end.round().toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}

/// Create a price range filter item.
class _PriceRangeItem extends PanelItem {
  final BuildContext context;
  final RangeValues currentRangeValues;
  final void Function(RangeValues) onChanged;

  const _PriceRangeItem(
      {required this.context,
      required super.itemTitle,
      super.itemDesc,
      required this.currentRangeValues,
      required this.onChanged});

  @override
  Widget get content {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _CustomRangeSlider(
          currentRangeValues: currentRangeValues,
          onChanged: onChanged,
        ));
  }
}

/// Create a filter item for the amenities.
class _AmenitiesItem extends PanelItem {
  final List<AmenitiesOption> amenitiesOptions;

  const _AmenitiesItem(
      {required super.itemTitle, required this.amenitiesOptions});

  @override
  Widget get content {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: amenitiesOptions.length,
          itemBuilder: (BuildContext context, int index) {
            return amenitiesOptions[index];
          }),
    );
  }
}

/// Customization of the [ChoiceChip] widget.
///
/// It allows to select only one option at a time from a list of options [any, 1, 2, 3, 4, 5].
class _CustomChoiceChip extends StatefulWidget {
  final int selectedIndex;
  final void Function(bool, int) onSelected;

  const _CustomChoiceChip(
      {required this.selectedIndex, required this.onSelected});

  @override
  State<_CustomChoiceChip> createState() => _CustomChoiceChipState();
}

class _CustomChoiceChipState extends State<_CustomChoiceChip> {
  final List<String> _options = <String>['Any', '1', '2', '3', '4'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      children: _options.asMap().entries.map((MapEntry<int, String> entry) {
        return ChoiceChip(
          label: Text(entry.value),
          selected: widget.selectedIndex == entry.key,
          onSelected: (value) {
            widget.onSelected(value, entry.key);
          },
        );
      }).toList(),
    );
  }
}

/// Create a filter item for the number of rooms.
///
/// The filter item allows to select the number of rooms from a list of options [any, 1, 2, 3, 4, 5].
///
/// The [content] is a [_CustomChoiceChip] widget.
class _RoomsItem extends PanelItem {
  final int selectedIndex;
  final void Function(String, bool, int) onSelected;

  const _RoomsItem(
      {required super.itemTitle,
      required this.selectedIndex,
      required this.onSelected});

  @override
  Widget get content {
    return _CustomChoiceChip(
      selectedIndex: selectedIndex,
      onSelected: (value, entry) {
        onSelected(itemTitle, value, entry);
      },
    );
  }
}
