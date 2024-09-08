import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The class [CustomNavigationBar] represents a navigation destination.
///
/// This class contains the icon and label of the destination.
///
/// The icon is displayed on the navigation bar, and the label is displayed below the icon.
///
/// The label is used to describe the destination.
///
/// The icon is used to represent the destination.
///
/// [isHost] is a boolean value that determines if the user is a host, in order to display the correct destinations.
/// 
/// [currentPageIndex] is the index of the current page.
/// 
/// [onDestinationSelected] is a function that is called when a destination is selected.
abstract class CustomNavigationBar extends StatefulWidget {
  final int currentPageIndex;
  final void Function(int) onDestinationSelected;

  const CustomNavigationBar(
      {super.key,
      required this.currentPageIndex,
      required this.onDestinationSelected});

  bool get isHost;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> studentDestination = [
      NavigationDestination(
        icon: const Icon(Icons.search),
        label: AppLocalizations.of(context)!.btnSearch,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bookmark_border_outlined),
        label: AppLocalizations.of(context)!.btnSavedAds,
      ),
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: AppLocalizations.of(context)!.btnChat,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        label: AppLocalizations.of(context)!.btnProfile,
      ),
    ];

    final List<Widget> hostDestination = [
      NavigationDestination(
        icon: const Icon(Icons.bookmark_border_outlined),
        label: AppLocalizations.of(context)!.btnAds,
      ),
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: AppLocalizations.of(context)!.btnChat,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        label: AppLocalizations.of(context)!.btnProfile,
      ),
    ];

    return NavigationBar(
      destinations: widget.isHost ? hostDestination : studentDestination,
      onDestinationSelected: (int index) {
        widget.onDestinationSelected(index);
      },
      selectedIndex: widget.currentPageIndex,
    );
  }
}

class StudentNavigationBar extends CustomNavigationBar {
  const StudentNavigationBar(
      {super.key,
      required super.currentPageIndex,
      required super.onDestinationSelected});

  @override
  bool get isHost => false;
}

class HostNavigationBar extends CustomNavigationBar {
  const HostNavigationBar(
      {super.key,
      required super.currentPageIndex,
      required super.onDestinationSelected});

  @override
  bool get isHost => true;
}
