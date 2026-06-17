import 'package:waveon/core/enums.dart';

class UserModel {
  UserModel._internal();
  static final UserModel instance = UserModel._internal();

  UserRole role = UserRole.none;
  String? username;
}
