import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  int xp;

  @HiveField(4)
  String? avatarUrlSmall;

  @HiveField(5)
  String? avatarUrlFull;

  UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.xp = 0,
    this.avatarUrlSmall,
    this.avatarUrlFull,
  });
}
