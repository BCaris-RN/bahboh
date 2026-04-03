String formatClock(int milliseconds) {
  final int totalSeconds = (milliseconds / 1000).ceil().clamp(0, 5999);
  final int minutes = totalSeconds ~/ 60;
  final int seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
