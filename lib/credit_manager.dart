class CreditManager {
  int _credits = 0;

  int get credits => _credits;

  void addCredits(int amount) {
    _credits += amount;
  }

  void deductCredits(int amount) {
    if (_credits >= amount) {
      _credits -= amount;
    } else {
      // Handle case where there aren't enough credits
    }
  }
}
