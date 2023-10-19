import 'package:dio/dio.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/const/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Retro_Api {
  Dio Dio_Data() {
    final dio = Dio();
    String? t = SharedPreferenceHelper.getString(Preferences.auth_token);
    dio.options.headers["Accept"] =
        "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 3000;
    if (t != "N/A") {
      dio.options.headers["Authorization"] = "Bearer " + t!;
    }
    return dio;
  }
}

class Retro_Api2 {
  Dio Dio_Data2() {
    final dio = Dio();
    dio.options.headers["Accept"] =
        "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 3000;
    return dio;
  }
}
