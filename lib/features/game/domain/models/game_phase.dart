enum GamePhase {
  boot,
  preRound,
  playing,
  paused,
  resolving,
  success,
  failure;

  bool get isTerminal => this == GamePhase.success || this == GamePhase.failure;
}
