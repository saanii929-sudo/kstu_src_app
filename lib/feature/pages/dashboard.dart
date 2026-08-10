// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:src_kstu_app/components/side_menu.dart';
import 'package:src_kstu_app/services/connectivity_provider.dart';
import 'package:src_kstu_app/feature/pages/news_details.dart';
import 'package:src_kstu_app/feature/pages/notice_board_shimmer.dart';
import 'package:src_kstu_app/feature/pages/notice_board.dart';
import 'package:src_kstu_app/feature/pages/trending_shimmer.dart';
import 'package:src_kstu_app/feature/pages/user_profile.dart';
import 'package:src_kstu_app/models/announcement.dart';
import 'package:src_kstu_app/models/constant.dart';
import 'package:src_kstu_app/services/notice_board.dart';
import 'package:src_kstu_app/components/trending_component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:src_kstu_app/components/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:src_kstu_app/services/trending_news.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:src_kstu_app/feature/pages/error_pages/no_internet.dart';

import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  var name;
  var index;
  var image;
  var id;
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;
  bool isLoading = false;

  @override
  initState() {
    _checkConnectivity();
    requestNotificationPermission(context);
    ConnectivityProvider();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    getUser();
    listenForPushNotifications(context);
    super.initState();
  }

  Future<void> _checkConnectivity() async {}
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isSideBarClosed = true;
  bool isSideMenuClosed = true;

  void getUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      name = localStorage.getString('name');
      index = localStorage.getInt('index');
      image = localStorage.getString('user_img');
      id = localStorage.getInt('id');
    });
  }

  Future<bool?> _showPrePermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Stay Updated!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'We need your permission to send you important updates and notifications.'),
                Text('Would you like to enable notifications?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Not Now'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Allow'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPostDenialDialog(BuildContext context) async {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Notifications Disabled'),
          content: const Text(
            'You have disabled notifications. You can enable them later from the app settings if you change your mind.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    try {
      if (!context.mounted) return;
      final SharedPreferences localStorage =
          await SharedPreferences.getInstance();
      final bool hasRequestedPermissionBefore =
          localStorage.getBool('notification_permission_requested') ?? false;

      final currentStatus = OneSignal.Notifications.permission;
      debugPrint("Current notification permission status: $currentStatus");

      if (currentStatus == OSNotificationPermission.authorized) {
        debugPrint("Notification permission already authorized.");
        await registerUserForPushNotification();
        return;
      }
      bool? userAgreedToSystemPrompt = hasRequestedPermissionBefore
          ? true
          : await _showPrePermissionDialog(context);

      if (userAgreedToSystemPrompt == true) {
        if (!context.mounted) return;

        await localStorage.setBool('notification_permission_requested', true);
        final bool permissionWasGranted =
            await OneSignal.Notifications.requestPermission(true);

        if (permissionWasGranted) {
          debugPrint("Notification permission granted by user!");
          await registerUserForPushNotification();
        } else {
          debugPrint("Notification permission denied by user or system.");
          if (context.mounted) {
            _showPostDenialDialog(context);
          }
        }
      } else {
        debugPrint(
            "User declined to see the system notification permission prompt.");
      }
    } catch (e) {
      debugPrint("Error in notification permission flow: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error requesting permissions: $e")),
        );
      }
    }
  }

  Future<void> registerUserForPushNotification() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();
    final int? userId = localStorage.getInt('id');

    if (userId == null) {
      debugPrint(
          "No userId found in local storage. User might not be logged in.");
      return;
    }

    final String externalUserId = userId.toString();
    debugPrint(
        "Attempting to login to OneSignal with externalUserId: $externalUserId");

    try {
      await OneSignal.login(externalUserId);
      debugPrint("OneSignal.login('$externalUserId') called successfully.");
    } catch (e) {
      debugPrint("Error during OneSignal.login: $e");
    }
  }

  // Navigation on tap is handled globally in main.dart (addClickListener) so
  // it works the same way whether the app is in the foreground, background,
  // or was cold-started by the tap. This listener only controls whether the
  // notification is shown while the app happens to already be open -
  // it must not navigate on its own, or arrival would jump the user away
  // before they ever tap anything.
  void listenForPushNotifications(BuildContext context) {
    debugPrint("Setting up OneSignal notification listeners");

    OneSignal.Notifications.addForegroundWillDisplayListener(
        (OSNotificationWillDisplayEvent event) async {
      try {
        final notification = event.notification;
        debugPrint(
            "Foreground notification received: ${notification.notificationId}");
        await _handleNotificationDisplay(event, notification);
        await _refreshAnnouncementLists(context);
      } catch (e, stackTrace) {
        debugPrint("Error handling notification: $e");
        debugPrint("Stack trace: $stackTrace");
      }
    });
  }

  // The lists below are fetched inline inside FutureBuilders in build(), so a
  // provider-level notifyListeners() alone won't re-run them - only a
  // setState() on this widget will. Without this, an announcement pushed
  // while the user is already sitting on the dashboard wouldn't show up
  // until they navigated away and back.
  Future<void> _refreshAnnouncementLists(BuildContext context) async {
    if (!context.mounted) return;
    final noticeProvider =
        Provider.of<NoticeBoardProvider>(context, listen: false);
    final trendProvider =
        Provider.of<TrendingNewsProvider>(context, listen: false);
    await Future.wait([
      noticeProvider.fetchNotice(1),
      trendProvider.fetchTrend(1),
    ]);
    if (mounted) setState(() {});
  }

  Future<void> _handleNotificationDisplay(
    OSNotificationWillDisplayEvent event,
    OSNotification notification,
  ) async {
    event.preventDefault();
    debugPrint("Prevented default notification display");
    final shouldShowNotification = true;
    if (shouldShowNotification) {
      notification.display();
      debugPrint("Manually displayed notification");
    }
  }

  @override
  Widget build(BuildContext context) {
    SimpleFontelicoProgressDialog dialog =
        SimpleFontelicoProgressDialog(context: context);
    final noticeProvider =
        Provider.of<NoticeBoardProvider>(context, listen: false);
    final trendProvider =
        Provider.of<TrendingNewsProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: topColor,
        // extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: topColor,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "$name",
                style: GoogleFonts.poppins(
                    color: bottomColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              Text(
                "$index",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              )
            ],
          ),
          leading: Builder(builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, top: 17),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 3),
                          blurRadius: 8)
                    ]),
                child: Icon(Icons.menu),
              ),
            );
          }),
          actions: [
            GestureDetector(
              onTap: () async {
                dialog.show(
                    message: 'Waiting...',
                    type: SimpleFontelicoProgressDialogType.hurricane);
                await Future.delayed(Duration(seconds: 1));
                dialog.hide();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserProfilePage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 18, right: 15),
                child: Stack(
                  children: [
                    CircleAvatar(
                      maxRadius: 24,
                      minRadius: 24,
                      backgroundColor: bottomColor,
                      backgroundImage: image != "1"
                          ? NetworkImage("$user_img_uri$image")
                          : NetworkImage(
                              "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                            ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        minRadius: 7,
                        maxRadius: 7,
                        backgroundColor: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        drawer: SideMenu(),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                Row(children: [
                  Container(
                    color: bottomColor,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  Container(
                    color: topColor,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 25,
                      decoration: const BoxDecoration(
                          color: topColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Consumer<ConnectivityProvider>(
                          builder: (context, provider, _) {
                        if (provider.status == ConnectivityStatus.Offline) {
                          //
                          return Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 250,
                              decoration: BoxDecoration(
                                  color: bottomColor,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30))),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 18.0),
                                  child: Container(
                                    width: double.infinity,
                                    // height: 300,
                                    decoration: BoxDecoration(
                                      color: topColor,
                                      borderRadius: BorderRadius.circular(40),
                                      image: DecorationImage(
                                        image: ExactAssetImage(
                                            'assets/images/wayera.png'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          height: 200,
                                          // color:Colors.red,
                                          child: Text(
                                            'Aww snap, no internet connection!',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )));
                        } else {
                          return Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height - 50,
                            decoration: const BoxDecoration(
                                color: bottomColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30))),
                            child: NestedScrollView(
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                dragStartBehavior: DragStartBehavior.start,
                                headerSliverBuilder:
                                    (context, innerBoxIsScrolled) {
                                  return [];
                                },
                                body: ListView(
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 15.0),
                                      child: Text(
                                        "Notice Board",
                                        style: GoogleFonts.poppins(
                                            color: topColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    FutureBuilder<List<Announcement>>(
                                      future: noticeProvider.fetchNotice(1),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: SizedBox(
                                                  height: 243,
                                                  child: NoticeBoardShimmer()));
                                        } else if (snapshot.hasError) {
                                          return Center();
                                        } else {
                                          final noticeboard = snapshot.data!;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: SizedBox(
                                              height: 250,
                                              child: ListView.builder(
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount:
                                                    noticeboard.length + 1,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return index !=
                                                          noticeboard.length
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            dialog.show(
                                                                message:
                                                                    'Waiting...',
                                                                type: SimpleFontelicoProgressDialogType
                                                                    .hurricane);
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1));
                                                            dialog.hide();
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: ((context) =>
                                                                        DetailNews(
                                                                            title:
                                                                                noticeboard[index].id))));
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 15.0,
                                                            ),
                                                            child: Container(
                                                              width: 160,
                                                              height: 150,
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      topColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Column(
                                                                  // mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          130,
                                                                      //
                                                                      // ignore: unnecessary_null_comparison
                                                                      decoration: BoxDecoration(
                                                                          // ignore: unnecessary_null_comparison
                                                                          image: noticeboard[index].featuredImage == null ? DecorationImage(image: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"), fit: BoxFit.fill) : DecorationImage(image: NetworkImage("$announcement_imgUri${noticeboard[index].featuredImage}"), fit: BoxFit.fill),
                                                                          color: topColor,
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Text(
                                                                      noticeboard[
                                                                              index]
                                                                          .title
                                                                          .trim(),
                                                                      style: GoogleFonts.poppins(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              17.5),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                      noticeboard[
                                                                              index]
                                                                          .createdAtFormatted
                                                                          .split(
                                                                              ', ')[1],
                                                                      style: GoogleFonts.poppins(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300,
                                                                          fontSize:
                                                                              12),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .fade,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : noticeboard.length >= 10
                                                          ? SizedBox(
                                                              width: 50,
                                                              height: 50,
                                                              child:
                                                                  DecoratedBox(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    color:
                                                                        topColor,
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              AllNoticeBoardPage()),
                                                                    );
                                                                  },
                                                                  child: Center(
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      color:
                                                                          topColor,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Container();
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 10.0),
                                      child: Text(
                                        "What's trending?",
                                        style: GoogleFonts.poppins(
                                            color: topColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    FutureBuilder<List<Announcement>>(
                                      // initialData: [],
                                      future: trendProvider.fetchTrend(1),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return TrendingShimmer();
                                        } else if (snapshot.hasError) {
                                          return noInternet();
                                        } else {
                                          final trend = snapshot.data!;

                                          return TrendingComponent(
                                              gottenData: trend,
                                              showRefresh: false,
                                              page: 2,
                                              hasLimit: true,
                                              isTrending: true);
                                        }
                                      },
                                    )
                                  ],
                                )),
                          );
                        }
                      }),
                    ),
                  ],
                )
              ]),
            ),
          ],
        ));
  }
}

class HeadPicture extends StatelessWidget {
  const HeadPicture({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserProfilePage()));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Stack(
          children: const [
            CircleAvatar(
              maxRadius: 24,
              minRadius: 24,
              backgroundColor: bottomColor,
              backgroundImage: AssetImage("assets/images/student_profile.jpeg"),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                minRadius: 7,
                maxRadius: 7,
                backgroundColor: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}
