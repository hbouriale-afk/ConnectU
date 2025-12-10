class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int? _userId;
  String? _userEmail;
  String? _userName;
  String? _userMajor;
  String? _userYear;
  List<String>? _userInterests;
  String? _userMood = 'Happy';

  // Getters
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userMajor => _userMajor;
  String? get userYear => _userYear;
  List<String>? get userInterests => _userInterests;
  String? get userMood => _userMood;

  // Setters
  void setUserData({
    required int userId,
    required String email,
    required String name,
    String? major,
    String? year,
    List<String>? interests,
  }) {
    _userId = userId;
    _userEmail = email;
    _userName = name;
    _userMajor = major;
    _userYear = year;
    _userInterests = interests;
  }

  void setMood(String mood) {
    _userMood = mood;
  }

  void setInterests(List<String> interests) {
    _userInterests = interests;
  }

  void clearSession() {
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userMajor = null;
    _userYear = null;
    _userInterests = null;
    _userMood = 'Happy';
  }

  bool isLoggedIn() => _userId != null;
}
