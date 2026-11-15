import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:src_kstu_app/services/campus_maps_service.dart';
import 'package:src_kstu_app/services/connectivity_provider.dart';
import 'package:src_kstu_app/feature/pages/loading.dart';
import 'package:src_kstu_app/feature/pages/news_details.dart';
import 'package:src_kstu_app/services/key_moments_service.dart';
import 'package:src_kstu_app/services/landmark_places.dart';
import 'package:src_kstu_app/services/notice_board.dart';
import 'package:src_kstu_app/services/trending_news.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("a8a3a92a-86cd-41b5-8efe-2e5badaf01d0");
  _listenForNotificationClicks();
  await FlutterDownloader.initialize(
    debug: true,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => NoticeBoardProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => TrendingNewsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => KeyMomentProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CampusMapProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LandmarkProvider(),
      ),
      ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      // ChangeNotifierProvider(create: (_) => AnnouncementPaginationProvider()
      // ),
    ],
    child: MyApp(),
  ));
}

void _listenForNotificationClicks() {
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    final rawId = data?['announcemet_id'];
    if (rawId == null) return;
    final announcementId =
        rawId is int ? rawId : int.tryParse(rawId.toString());
    if (announcementId == null) return;
    _navigateToAnnouncement(announcementId);
  });
}

Future<void> _navigateToAnnouncement(int announcementId) async {
  var navigator = navigatorKey.currentState;
  var attempts = 0;
  while (navigator == null && attempts < 50) {
    await Future.delayed(const Duration(milliseconds: 100));
    navigator = navigatorKey.currentState;
    attempts++;
  }
  navigator?.push(
    MaterialPageRoute(builder: (_) => DetailNews(title: announcementId)),
  );
}

// zamaani
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SRC-KsTU',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
          )),
      home: LoadingPage(),
    );
  }
}
