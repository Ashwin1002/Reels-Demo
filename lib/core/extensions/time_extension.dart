extension DurationExtension on Duration {
  String get formattedDuration {
    var seconds = inMilliseconds ~/ 1000;
    final hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString =
        hours >= 10
            ? '$hours'
            : hours == 0
            ? '00'
            : '0$hours';
    final minutesString =
        minutes >= 10
            ? '$minutes'
            : minutes == 0
            ? '00'
            : '0$minutes';
    final secondsString =
        seconds >= 10
            ? '$seconds'
            : seconds == 0
            ? '00'
            : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
    return formattedTime;
  }
}
