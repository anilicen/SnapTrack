class StringUtils {
  static String formatRouteLengthShort(double routeLength) {
    double kilometers = (routeLength / 1000);
    int meters = (routeLength % 1000).round();

    if (kilometers > 0) {
      return '$kilometers km ';
    } else {
      return '$meters mt';
    }
  }

  static String formatRouteDuration(Duration routeDuration) {
    int hours = routeDuration.inHours;
    int minutes = routeDuration.inMinutes % 60;

    if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  static String formatRouteDurationShort(Duration routeDuration) {
    int hours = routeDuration.inHours;
    int minutes = routeDuration.inMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return '0 mins';
    }

    return '${hours > 0 ? '$hours ${hours == 1 ? 'hr' : 'hrs'}' : ''} ${minutes > 0 ? '$minutes ${minutes == 1 ? 'min' : 'mins'}' : ''}';
  }

  static String createUrl(String param) {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        param.replaceAll(RegExp('[^A-Za-z0-9]'), '').toLowerCase();
  }

  List<String> generateSubstrings(String input) {
    String lowercasedInput = input.toLowerCase();
    List<String> substrings = [];
    int length = lowercasedInput.length;

    for (int i = 0; i < length; i++) {
      for (int j = i + 1; j <= length; j++) {
        substrings.add(lowercasedInput.substring(i, j));
      }
    }
    return substrings;
  }
}
