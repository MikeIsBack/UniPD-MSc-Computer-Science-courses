import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';

/// [PhotoCarousel] is a widget that displays a carousel of images.
/// It is used in the app to display the images of a room or apartment.
/// It has a [CarouselSlider] widget that displays the images and a [LightBackButton] widget to go back.
/// In addition to that, it has a [_PhotoCounter] widget that displays the current image number.
///
/// The [PhotoCarousel] widget is an abstract class that defines the basic structure of the carousel.
/// It has two subclasses: [HostPhotoCarousel] and [StudentPhotoCarousel].
///
/// The [HostPhotoCarousel] is used by the host to display the images of the room or apartment, with the following buttons:
/// - [EditButton], to edit the images;
/// - [DeleteButton], to delete the images.
///
/// The [StudentPhotoCarousel] is used by the student to display the images of the room or apartment, with the following buttons:
/// - [BookmarkButton], to bookmark the room or apartment.
abstract class PhotoCarousel extends StatefulWidget {
  final List<Image> items;
  final bool isWizardPage;
  final bool? isSaved;
  final void Function()? onSavePressed;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;
  final void Function() onBackPressed;

  const PhotoCarousel(
      {super.key,
      required this.items,
      this.isWizardPage = false,
      this.isSaved,
      this.onSavePressed,
      this.onDeletePressed,
      this.onEditPressed,
      required this.onBackPressed});

  bool get isStudent;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    double carouselHeight = 348.0.h;

    return Stack(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: carouselHeight,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.items.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: i.image,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
            child: LightBackButton(
              onPressed: widget.onBackPressed,
            ),
          ),
        ),
        widget.isStudent
            ? Positioned(
                height: carouselHeight,
                right: 5,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BookmarkButton(
                        size: 50,
                        isSaved: widget.isSaved!,
                        onPressed: widget.onSavePressed,
                      ),
                      _PhotoCounter(current: _current, widget: widget)
                    ],
                  ),
                ),
              )
            : widget.isWizardPage
                ? Positioned(
                    right: 5,
                    height: carouselHeight,
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          const SizedBox(),
                          _PhotoCounter(current: _current, widget: widget),
                        ],
                      ),
                    ),
                  )
                : Positioned(
                    right: 5,
                    height: carouselHeight,
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          EditButton(
                            onPressed: widget.onEditPressed!,
                          ),
                          DeleteButton(onPressed: widget.onDeletePressed!),
                          _PhotoCounter(current: _current, widget: widget),
                        ],
                      ),
                    ),
                  ),
      ],
    );
  }
}

/// [_PhotoCounter] is a widget that displays the current image number.
/// It is used in the [PhotoCarousel] widget to display the current image number.
class _PhotoCounter extends StatelessWidget {
  const _PhotoCounter({
    required int current,
    required this.widget,
  }) : _current = current;

  final int _current;
  final PhotoCarousel widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
        child: Text(
          "${_current + 1}/${widget.items.length}",
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// [HostPhotoCarousel] is a widget that displays a carousel of images for the host.
class HostPhotoCarousel extends PhotoCarousel {
  const HostPhotoCarousel(
      {super.key, required super.items, required super.isWizardPage, required super.onEditPressed, required super.onDeletePressed, required super.onBackPressed});

  @override
  bool get isStudent => false;
}

/// [StudentPhotoCarousel] is a widget that displays a carousel of images for the student.
class StudentPhotoCarousel extends PhotoCarousel {
  const StudentPhotoCarousel(
      {super.key,
      required super.items,
      required super.isSaved,
      required super.onSavePressed,
      required super.onBackPressed});

  @override
  bool get isStudent => true;
}
