class GameResult {
  const GameResult({
    required this.didClearRound,
    required this.finalScore,
    required this.summary,
  });

  final bool didClearRound;
  final int finalScore;
  final String summary;
}
