import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/screens/search_results_page.dart';
import 'package:room_finder/style/color_palette.dart';

/// This class contains the [CustomSearchBar] widget, which is a custom search bar that can be used in the app.
///
/// - [hintText] is the text that appears as a hint in the search bar.
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final bool isLogged;
  final String currentUserUid;
  final bool isInvokedFromHome;

  const CustomSearchBar({
    super.key, 
    this.hintText, 
    required this.isLogged,
    required this.currentUserUid,
    required this.isInvokedFromHome});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late SearchController _searchController;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _searchController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SizedBox(
          height: 48.h,
          child: SearchBar(
            textStyle: WidgetStateProperty.all<TextStyle>(
              Theme.of(context).textTheme.bodyMedium!,
            ),
            controller: _searchController,
            backgroundColor: WidgetStateProperty.all<Color>(
                ColorPalette.lavenderBlue.withOpacity(0.5)),
            elevation: WidgetStateProperty.all<double>(0),
            shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
            hintText: widget.hintText,
            trailing: [
              IconButton(
                onPressed: _isButtonEnabled
                    ? () {
                        String searchCity = _searchController.text.trim();

                        if(widget.isInvokedFromHome){
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return SearchResultsPage(
                              isLogged: widget.isLogged,
                              searchCity: searchCity,
                              currentUserUid: widget.currentUserUid
                            );
                          }));
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return SearchResultsPage(
                              isLogged: widget.isLogged,
                              searchCity: searchCity,
                              currentUserUid: widget.currentUserUid
                            );
                          }));
                        }
                      }
                    : null,
                icon: const Icon(Icons.search),
              )
            ],
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return [];
      },
    );
  }
}
