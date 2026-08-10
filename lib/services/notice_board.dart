import 'dart:convert';
import 'package:src_kstu_app/models/announcement.dart';
import 'package:src_kstu_app/models/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NoticeBoardProvider extends ChangeNotifier {
  List<Announcement> _notice = [];

  List<Announcement> get notice => _notice;

  Future<List<Announcement>> fetchNotice(int currentPageNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String cacheKey = 'cached_notices_page_$currentPageNumber';
    String token = await getToken();

    final response = await http.get(
      Uri.parse('$noticeUrl?page=$currentPageNumber'),
      headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData =
          json.decode(response.body)['announcements'];
      final List<dynamic> data = jsonData['data'];

      List<Announcement> newNotices =
          data.map((e) => Announcement.fromJson(e)).toList();

      final cachedRaw = prefs.getString(cacheKey);
      final newRaw = json.encode(data);

      if (cachedRaw != newRaw) {
        await prefs.setString(cacheKey, newRaw);
        _notice = newNotices;
        notifyListeners();
        return _notice;
      } else if (cachedRaw != null) {
        final cachedData = json.decode(cachedRaw);
        _notice = cachedData
            .map<Announcement>((e) => Announcement.fromJson(e))
            .toList();
        notifyListeners();
        return _notice;
      } else {
        _notice = newNotices;
        notifyListeners();
        return _notice;
      }
    } else if (response.statusCode == 401) {
      throw Exception(jsonDecode(response.body)['message']);
    } else {
      final fallback = prefs.getString(cacheKey);
      if (fallback != null) {
        final cachedData = json.decode(fallback);
        _notice = cachedData
            .map<Announcement>((e) => Announcement.fromJson(e))
            .toList();
        notifyListeners();
        return _notice;
      } else {
        throw Exception('Failed to fetch noticeboard!');
      }
    }
  }

  Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token") ?? '';
  }
}
