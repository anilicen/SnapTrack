import 'package:st/src/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> registerUser(User user, String password);
  Future<void> logIn(String email, String password);
  Future<bool> checkIfUsernameIsAvaliable(String username);
  Future<bool?> getIfEmailAvaliableForRegister();
  Future<bool?> getUserCredentialsAreFoundForLogin();
  Future<bool?> getIsPasswordCorrectForLogin();
  Future<User> getUser();
  Future<void> updateProfilePicture(String pictureUrl);
  Future<void> signOut();
}
