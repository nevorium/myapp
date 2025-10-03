import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@Collection()
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uid;

  String? name;
  String? email;
  int xp;

  String? avatarUrlSmall; // 64x64
  String? avatarUrlFull; // 256x256

  UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.xp = 0,
    this.avatarUrlSmall,
    this.avatarUrlFull,
  });
}
