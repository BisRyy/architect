import 'dart:convert';
import 'package:architect/core/errors/exception.dart';
import 'package:architect/features/architect/data/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(AuthModel token);
  Future<AuthModel> getToken();
  Future<bool> isValid();
}

const String authCacheKey = 'auth';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences plugin;

  AuthLocalDataSourceImpl(this.plugin);

  @override
  Future<void> cacheToken(AuthModel token) {
    return plugin.setString(authCacheKey, json.encode(token.toJson()));
  }

  @override
  Future<AuthModel> getToken() {
    final token = plugin.getString(authCacheKey);
    if (token != null) {
      Map<String, dynamic> jsonMap = json.decode(token);
      return Future.value(AuthModel.fromJson(jsonMap));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<bool> isValid() async {
    try {
      final auth = await getToken();
      final token = auth.accessToken;
      final Map<String, dynamic> decodedMap = json
          .decode(String.fromCharCodes(base64Url.decode(token.split('.')[1])));
      int expTimestamp = decodedMap['exp'];
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return currentTimestamp < expTimestamp;
    } on CacheException {
      return false;
    }
  }
}
