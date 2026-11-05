// ignore_for_file: use_build_context_synchronously

import 'package:src_kstu_app/components/colors.dart';
import 'package:src_kstu_app/services/connectivity_provider.dart';
import 'package:src_kstu_app/feature/pages/dashboard.dart';
import 'package:src_kstu_app/feature/pages/forgot_password.dart';
import 'package:src_kstu_app/models/api_response.dart';
import 'package:src_kstu_app/models/user.dart';
import 'package:src_kstu_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src_kstu_app/components/app_animations.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool ispassword = true;
  double isOnTap = 50;
  int reduceConatiner = 4;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _loginUser() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    ApiResponse response =
        await login(emailController.text, passwordController.text);
    if (response.error == null) {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        _saveAndRedirectToDashboard(response.data as User);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please connect to the internet'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          elevation: 2.0,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      }
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
        backgroundColor: Colors.red.shade700,
        elevation: 2.0,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.yellow,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
    }
  }

  void _saveAndRedirectToDashboard(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", user.token ?? '');
    await prefs.setInt("id", user.id ?? 0);

    await prefs.setString("name", user.name ?? '');
    await prefs.setInt("index", user.indexNo ?? 0);
    await prefs.setString("gender", user.gender ?? '');
    await prefs.setString("level", user.currentLevel ?? '');
    await prefs.setString("user_img", user.userImg ?? '');
    await prefs.setBool('hasOpended', true);
    await prefs.setInt("semester", user.currentSem ?? 0);
    await prefs.setString("program", user.programName ?? "");
    await prefs.setString("department", user.deptName ?? "");
    await prefs.setString("faculty", user.facultyName ?? "");
    await prefs.setString("phone", user.phone ?? "");
    await prefs.setString("email", user.email ?? '');
    await prefs.setString("image", user.userImg ?? '');
    await prefs.setString("yrOfAdmission", user.yrOfAdmission ?? '');
    await prefs.setString("yrOfCompletion", user.yrOfCompletion ?? '');
    var name = prefs.getString('name');
    // Grab the messenger before navigating: pushAndRemoveUntil unmounts
    // LoginPage, so ScaffoldMessenger.of(context) would be stale afterwards
    // (the snackbar would show but its Dismiss action would be a no-op).
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text('Welcome, $name'),
      backgroundColor: topColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Dismiss',
        disabledTextColor: Colors.white,
        textColor: Colors.yellow,
        onPressed: () {
          messenger.hideCurrentSnackBar();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    SimpleFontelicoProgressDialog dialog =
        SimpleFontelicoProgressDialog(context: context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          isOnTap = 50;
          reduceConatiner = 4;
        });
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            isOnTap = 50;
            reduceConatiner = 4;
          });
        },
        child: Scaffold(
            backgroundColor: topColor,
            resizeToAvoidBottomInset: false,
            body: Semantics(
              label: "Login Page",
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                          height: double.infinity,
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
                            Consumer<ConnectivityProvider>(
                                builder: (context, provider, _) {
                              if (provider.status ==
                                  ConnectivityStatus.Offline) {
                                SnackBar(
                                    content: Text("No internet connection"),
                                    backgroundColor: topColor,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      disabledTextColor: Colors.white,
                                      textColor: Colors.yellow,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      },
                                    ));
                                return Column(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                          decoration: const BoxDecoration(
                                              color: topColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(30))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: Image.asset(
                                                  "assets/images/f.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 25,
                                              ),
                                               Text(
                                                "No internet connection",
                                                style: GoogleFonts.poppins(
                                                    color: bottomColor,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 30),
                                              )
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: bottomColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(30))),
                                          child: Column(children: [
                                            Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18.0),
                                              child: Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color: topColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: Text(
                                                    "No internet connection",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                          ]),
                                        ))
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                          decoration: const BoxDecoration(
                                              color: topColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(30))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: Image.asset(
                                                  "assets/images/f.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ).appPopIn(duration: AppMotion.slow),
                                              const SizedBox(
                                                height: 24,
                                              ),
                                               Text(
                                                "SIGN IN",
                                                style: GoogleFonts.poppins(
                                                    color: bottomColor,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 30),
                                              ).appEntrance(
                                                  delay: const Duration(
                                                      milliseconds: 200)),
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: reduceConatiner,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: bottomColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(30))),
                                          child: Form(
                                            key: formkey,
                                            child: Column(children: [
                                              SizedBox(
                                                height: isOnTap,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 18.0,
                                                    vertical: 10),
                                                child: TextFormField(
                                                  onTap: () {
                                                    setState(() {
                                                      isOnTap = 20;
                                                      reduceConatiner = 6;
                                                    });
                                                  },
                                                  validator: ((value) {
                                                    if (value!.isEmpty) {
                                                      return "Index Number or Email field is required";
                                                    }
                                                    return null;
                                                  }),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  controller: emailController,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(10),
                                                    label: Text("Index Number or Email"),
                                                    hintText: '',
                                                    prefixIcon:
                                                        Icon(Icons.email),
                                                    border:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 18.0,
                                                    vertical: 10),
                                                child: TextFormField(
                                                  onTap: () {
                                                    isOnTap = 20;
                                                    reduceConatiner = 6;
                                                  },
                                                  validator: ((value) {
                                                    if (value!.isEmpty) {
                                                      return "Password field is required";
                                                    }
                                                    return null;
                                                  }),
                                                  keyboardType: TextInputType
                                                      .visiblePassword,
                                                  controller:
                                                      passwordController,
                                                  obscureText: ispassword,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(10),
                                                    label: Text("Password"),
                                                    hintText: '',
                                                    prefixIcon:
                                                        Icon(Icons.lock),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(ispassword
                                                          ? Icons
                                                              .visibility_off
                                                          : Icons.visibility),
                                                      onPressed: () {
                                                        setState(() {
                                                          ispassword =
                                                              !ispassword;
                                                        });
                                                      },
                                                    ),
                                                    border:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 18.0),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    dialog.show(
                                                        message: 'Waiting...',
                                                        type:
                                                            SimpleFontelicoProgressDialogType
                                                                .hurricane);
                                                    await Future.delayed(
                                                        Duration(seconds: 1));
                                                    dialog.hide();
                                                    if (formkey.currentState!
                                                        .validate()) {
                                                      setState(() {
                                                        loading = true;
                                                        _loginUser();
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: topColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10)),
                                                    child: Center(
                                                      child: loading
                                                          ? SpinKitFadingCircle(
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return DecoratedBox(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: index
                                                                            .isEven
                                                                        ? bottomColor
                                                                        : bottomColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                );
                                                              },
                                                              size: 40,
                                                            )
                                                          : Text(
                                                              "SIGN IN",
                                                              style: GoogleFonts.poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end, // Align widgets to the right
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        // Show loading dialog
                                                        dialog.show(
                                                          message:
                                                              'Waiting...',
                                                          type:
                                                              SimpleFontelicoProgressDialogType
                                                                  .hurricane,
                                                        );
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 1));
                                                        dialog.hide();
              
                                                        // Navigate to ForgotPasswordPage and remove all previous routes
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ForgotPasswordPage()));
                                                      },
                                                      child: Text(
                                                        'Forgot Password?',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: topColor,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            16), // Optional spacing between elements
                                                  ],
                                                ),
                                              ),
                                            ].appStaggered()),
                                          ),
                                        ))
                                  ],
                                );
                              }
                            })
                          ])))),
            )),
      ),
    );
  }
}
