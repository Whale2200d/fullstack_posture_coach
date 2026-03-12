// Commit 21: 사용자 신체 정보 (키/체중/연령) 로컬 저장 서비스

class UserProfile {
  const UserProfile({
    required this.heightCm,
    required this.weightKg,
    required this.ageYears,
  });

  final int heightCm;
  final int weightKg;
  final int ageYears;
}

class ProfileService {
  ProfileService._();

  factory ProfileService.inMemory() => ProfileService._();

  UserProfile? _currentProfile;

  UserProfile? get currentProfile => _currentProfile;

  void save(UserProfile profile) {
    _currentProfile = profile;
  }
}

