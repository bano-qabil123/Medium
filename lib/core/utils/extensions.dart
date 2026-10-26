import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtensions on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get the current media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get the current screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get the current screen width
  double get screenWidth => screenSize.width;
  
  /// Get the current screen height
  double get screenHeight => screenSize.height;
  
  /// Get the current orientation
  Orientation get orientation => mediaQuery.orientation;
  
  /// Check if the current orientation is portrait
  bool get isPortrait => orientation == Orientation.portrait;
  
  /// Check if the current orientation is landscape
  bool get isLandscape => orientation == Orientation.landscape;
  
  /// Get the current device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;
  
  /// Get the current text scale factor
  double get textScaleFactor => mediaQuery.textScaleFactor;
  
  /// Check if the current theme is dark
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// Check if the current theme is light
  bool get isLightMode => theme.brightness == Brightness.light;
  
  /// Show a snackbar
  void showSnackbar(String message, {Duration? duration, Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show a dialog
  Future<T?> showDialogWidget<T>({required Widget child, bool barrierDismissible = true}) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        child: child,
      ),
    );
  }
  
  /// Show a bottom sheet
  Future<T?> showBottomSheetWidget<T>({required Widget child, bool isScrollControlled = false}) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      builder: (context) => child,
    );
  }
  
  /// Pop the current route
  void pop() => Navigator.of(this).pop();
  
  /// Pop until a specific route
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
  
  /// Push a new route
  Future<T?> push<T>(Widget page, {bool fullscreenDialog = false}) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }
  
  /// Push a named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Push and remove until
  Future<T?> pushAndRemoveUntil<T>(Widget page, String untilRouteName) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => page),
      ModalRoute.withName(untilRouteName),
    );
  }
}

extension StringExtensions on String {
  /// Capitalize the first letter
  String get capitalize => this[0].toUpperCase() + substring(1);
  
  /// Capitalize each word
  String get capitalizeWords => split(' ').map((word) => word.capitalize).join(' ');
  
  /// Convert to title case
  String get toTitleCase => replaceAll(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().capitalizeWords;
  
  /// Check if the string is empty or null
  bool get isEmptyOrNull => isEmpty || this == 'null';
  
  /// Check if the string is not empty and not null
  bool get isNotEmptyOrNull => !isEmptyOrNull;
  
  /// Truncate the string to a specific length
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }
  
  /// Format as a slug
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'--+'), '-');
  }
  
  /// Check if the string is a valid email
  bool get isValidEmail => RegExp(r'^\S+@\S+\.\S+$').hasMatch(this);
  
  /// Check if the string is a valid URL
  bool get isValidUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;
  
  /// Check if the string is a valid username (alphanumeric + underscore)
  bool get isValidUsername => RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(this);
  
  /// Format as a readable date
  String formatDate({String? format}) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(format ?? 'MMM dd, yyyy').format(date);
    } catch (e) {
      return this;
    }
  }
  
  /// Format as a relative time (e.g., "2 hours ago")
  String formatRelativeTime() {
    try {
      final date = DateTime.parse(this);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return this;
    }
  }
  
  /// Calculate estimated read time in minutes
  int get estimatedReadTime {
    const wordsPerMinute = 200;
    final wordCount = split(RegExp(r'\s+')).length;
    return (wordCount / wordsPerMinute).ceil();
  }
}

extension DateTimeExtensions on DateTime {
  /// Format as a readable date
  String format({String? format}) => DateFormat(format ?? 'MMM dd, yyyy').format(this);
  
  /// Format as a relative time
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
  
  /// Check if the date is today
  bool get isToday => year == DateTime.now().year && month == DateTime.now().month && day == DateTime.now().day;
  
  /// Check if the date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Check if the date is in the future
  bool get isFuture => isAfter(DateTime.now());
  
  /// Check if the date is in the past
  bool get isPast => isBefore(DateTime.now());
}

extension NumExtensions on num {
  /// Clamp the value between min and max
  num clamp(num min, num max) => this < min ? min : (this > max ? max : this);
  
  /// Convert to duration in milliseconds
  Duration get milliseconds => Duration(milliseconds: toInt());
  
  /// Convert to duration in seconds
  Duration get seconds => Duration(seconds: toInt());
  
  /// Convert to duration in minutes
  Duration get minutes => Duration(minutes: toInt());
  
  /// Convert to duration in hours
  Duration get hours => Duration(hours: toInt());
  
  /// Convert to duration in days
  Duration get days => Duration(days: toInt());
  
  /// Check if the number is even
  bool get isEven => toInt() % 2 == 0;
  
  /// Check if the number is odd
  bool get isOdd => !isEven;
  
  /// Format as a file size
  String formatFileSize() {
    if (this < 1024) return '${toStringAsFixed(0)} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(2)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

extension IterableExtensions<E> on Iterable<E> {
  /// Check if the iterable is not empty
  bool get isNotEmpty => !isEmpty;
  
  /// Get the first element or null
  E? get firstOrNull => isEmpty ? null : first;
  
  /// Get the last element or null
  E? get lastOrNull => isEmpty ? null : last;
  
  /// Split the iterable into chunks of a specific size
  List<List<E>> chunk(int size) {
    final chunks = <List<E>>[];
    final list = toList();
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
  
  /// Group the iterable by a key
  Map<K, List<E>> groupBy<K>(K Function(E) key) {
    final map = <K, List<E>>{};
    for (final element in this) {
      final k = key(element);
      map.putIfAbsent(k, () => []).add(element);
    }
    return map;
  }
  
  /// Get all unique elements
  List<E> get unique => toSet().toList();
  
  /// Check if all elements satisfy a condition
  bool all(bool Function(E) test) => every(test);
  
  /// Check if any element satisfies a condition
  bool any(bool Function(E) test) => any(test);
  
  /// Get the sum of all elements (if they are numbers)
  num get sum => fold(0, (a, b) => a + (b as num));
  
  /// Get the average of all elements (if they are numbers)
  double get average => isEmpty ? 0 : sum / length;
}

extension ListExtensions<E> on List<E> {
  /// Swap two elements
  void swap(int i, int j) {
    final temp = this[i];
    this[i] = this[j];
    this[j] = temp;
  }
  
  /// Shuffle the list
  void shuffleList() {
    shuffle();
  }
  
  /// Get a random element
  E? get randomOrNull => isEmpty ? null : (this..shuffle()).first;
  
  /// Sort the list by a key
  void sortBy<K extends Comparable>(K Function(E) key, {bool descending = false}) {
    sort((a, b) => descending 
      ? Comparable.compare(key(b), key(a)) 
      : Comparable.compare(key(a), key(b)));
  }
}

extension WidgetExtensions on Widget {
  /// Wrap the widget with padding
  Widget pad({double? all, double? horizontal, double? vertical, 
    double? left, double? top, double? right, double? bottom}) {
    return Padding(
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: this,
    );
  }
  
  /// Wrap the widget with a container
  Widget container({Color? color, double? width, double? height, 
    EdgeInsetsGeometry? padding, EdgeInsetsGeometry? margin, 
    BoxDecoration? decoration, BoxConstraints? constraints}) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints,
      color: color,
      child: this,
    );
  }
  
  /// Wrap the widget with a center
  Widget center({double? widthFactor, double? heightFactor}) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }
  
  /// Wrap the widget with a sized box
  Widget sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }
  
  /// Wrap the widget with a flex
  Widget flex({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }
  
  /// Wrap the widget with a card
  Widget card({Color? color, double? elevation, EdgeInsetsGeometry? margin, 
    ShapeBorder? shape, bool? borderOnForeground}) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      borderOnForeground: borderOnForeground,
      child: this,
    );
  }
  
  /// Wrap the widget with a gesture detector
  Widget onTap(VoidCallback onTap, {MouseCursor? cursor}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: cursor ?? SystemMouseCursors.click,
        child: this,
      ),
    );
  }
  
  /// Wrap the widget with a visibility
  Widget visible(bool visible, {Widget? replacement}) {
    return Visibility(
      visible: visible,
      replacement: replacement ?? SizedBox.shrink(),
      child: this,
    );
  }
  
  /// Wrap the widget with a opacity
  Widget opacity(double opacity) {
    return Opacity(
      opacity: opacity,
      child: this,
    );
  }
  
  /// Wrap the widget with a hero
  Widget hero({required Object tag, Widget? placeholder}) {
    return Hero(
      tag: tag,
      child: this,
      placeholder: placeholder,
    );
  }
  
  /// Wrap the widget with a material
  Widget material({Color? color, double? elevation, EdgeInsetsGeometry? padding, 
    ShapeBorder? shape, bool? borderOnForeground}) {
    return Material(
      color: color,
      elevation: elevation,
      shape: shape,
      borderOnForeground: borderOnForeground,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: this,
      ),
    );
  }
}
