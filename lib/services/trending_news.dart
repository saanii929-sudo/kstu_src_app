import 'dart:convert';
import 'package:src_kstu_app/models/announcement.dart';
import 'package:src_kstu_app/models/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TrendingNewsProvider extends ChangeNotifier {
  List<Announcement> _trend = [];

  List<Announcement> get trend => _trend;

  Future<List<Announcement>> fetchTrend(int currentPageNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final cacheKey = 'cached_trend_page_$currentPageNumber';
    final cachedTrends = prefs.getString(cacheKey);
    String token = await getToken();

    final response = await http.get(
      Uri.parse('$trendingUrl?page=$currentPageNumber'),
      headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData =
          json.decode(response.body)['announcements'];
      final List<dynamic> data = jsonData['data'];

      final newTrendRaw = json.encode(data);
      final List<Announcement> newTrends =
          data.map((e) => Announcement.fromJson(e)).toList();
      if (cachedTrends != newTrendRaw) {
        await prefs.setString(cacheKey, newTrendRaw);
        _trend = newTrends;
        notifyListeners();
        return _trend;
      } else if (cachedTrends != null) {
        final cachedData = json.decode(cachedTrends);
        _trend = cachedData
            .map<Announcement>((e) => Announcement.fromJson(e))
            .toList();
        notifyListeners();
        return _trend;
      } else {
        _trend = newTrends;
        notifyListeners();
        return _trend;
      }
    } else if (response.statusCode == 401) {
      throw Exception(jsonDecode(response.body)['message']);
    } else {
      if (cachedTrends != null) {
        final List<dynamic> cachedData = json.decode(cachedTrends);
        _trend = cachedData.map((e) => Announcement.fromJson(e)).toList();
        notifyListeners();
        return _trend;
      }
      throw Exception('Failed to fetch trending board!');
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token") ?? '';
  }

  Future<Announcement> fetchTrendDetails(int trendId) async {
    String token = await getToken();
    final response = await http
        .get(Uri.parse('$announcementDetailUrl/$trendId'), headers: {
      "Accept": "application/json",
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      return Announcement.fromJson(jsonDecode(response.body)["data"]);
    } else if (response.statusCode == 401) {
      throw Exception(jsonDecode(response.body)['message']);
    } else {
      throw Exception('Failed to fetch data from api!');
    }
  }
}
