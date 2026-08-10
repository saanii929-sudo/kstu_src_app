import 'dart:convert';
import 'package:src_kstu_app/models/constant.dart';
import 'package:src_kstu_app/models/land-marks-model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LandmarkProvider extends ChangeNotifier {
  
  List<LandmarkModel> _key = [];

  List<LandmarkModel> get key => _key;
  
  Future<List<LandmarkModel>> fetchLandmarkPlace(int trendId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cached_landmark_$trendId';
  final cachedLandmarks = prefs.getString(cacheKey);

  String token = await getToken();
  final response = await http.get(
    Uri.parse('$landmarkPlaces/$trendId'),
    headers: {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> data = jsonData['data'];

    final newLandmarkRaw = jsonEncode(data);
    final List<LandmarkModel> newLandmarks =
        data.map((e) => LandmarkModel.fromJson(e)).toList();

    if (cachedLandmarks != newLandmarkRaw) {
      await prefs.setString(cacheKey, newLandmarkRaw);
      _key = newLandmarks;
      notifyListeners();
      return _key;
    } else if (cachedLandmarks != null) {
      final List<dynamic> cachedData = jsonDecode(cachedLandmarks);
      _key = cachedData.map((e) => LandmarkModel.fromJson(e)).toList();
      notifyListeners();
      return _key;
    } else {
      _key = newLandmarks;
      notifyListeners();
      return _key;
    }
  } else if (response.statusCode == 401) {
    throw Exception(jsonDecode(response.body)['message']);
  } else {
    // Use cache as fallback if available
    if (cachedLandmarks != null) {
      final List<dynamic> cachedData = jsonDecode(cachedLandmarks);
      _key = cachedData.map((e) => LandmarkModel.fromJson(e)).toList();
      notifyListeners();
      return _key;
    }
    throw Exception('Failed to fetch landmark places!');
  }
}

  
  Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token") ?? '';
  }

}
