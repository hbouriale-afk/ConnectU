class UserData {
  static final UserData _instance = UserData._internal();

  factory UserData() {
    return _instance;
  }

  UserData._internal();

  // User interests
  List<String> userInterests = [];
  String userMood = 'Happy';

  // Calculate match percentage based on shared interests
  int calculateMatchPercentage(List<String> otherInterests) {
    if (userInterests.isEmpty || otherInterests.isEmpty) {
      return 0;
    }

    int commonInterests = 0;
    for (String interest in userInterests) {
      if (otherInterests.contains(interest)) {
        commonInterests++;
      }
    }

    double matchPercentage =
        (commonInterests / userInterests.length) * 100;
    return matchPercentage.toInt();
  }

  // Update user interests
  void setUserInterests(List<String> interests) {
    userInterests = interests;
  }

  // Update user mood
  void setUserMood(String mood) {
    userMood = mood;
  }
}
