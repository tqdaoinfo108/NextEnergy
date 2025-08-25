class DateTimeUtils {
  static String getDateTimeString(int? time, {int subStringLastIndex = 16}) {
    return DateTime.fromMillisecondsSinceEpoch((time ?? 0) * 1000)
        .toString()
        .substring(0, subStringLastIndex);
  }
}
