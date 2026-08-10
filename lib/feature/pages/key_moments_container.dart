import 'package:src_kstu_app/components/colors.dart';
import 'package:src_kstu_app/models/annoucement_key_moment.dart';
import 'package:src_kstu_app/models/constant.dart';
import 'package:src_kstu_app/services/key_moments_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class KeyMomentContainer extends StatefulWidget {
  const KeyMomentContainer({super.key, required this.title});
  final int title;

  @override
  State<KeyMomentContainer> createState() => _KeyMomentContainerState();
}

class _KeyMomentContainerState extends State<KeyMomentContainer> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final keymoments = Provider.of<KeyMomentProvider>(context, listen: false);
    return FutureBuilder<List<AnnouncementKeyMoments>>(
        future: keymoments.fetchKeymoment(widget.title),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? topColor : topColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
                size: 70,
              ),
            );
          } else {
            final keymoments = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: keymoments.length,
                padding: EdgeInsets.only(bottom: 10),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Linkify(
                        text: keymoments[index].imageDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.justify,
                        onOpen: (link) async {
                          final uri = Uri.parse(link.url);
                          await launch(uri.toString());
                        },
                      ),
                      keymoments[index].image != ""
                          ? SizedBox(
                              height: 20,
                            )
                          : SizedBox.shrink(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          keymoments[index].image != ""
                              ? Container(
                                  width: double.infinity,
                                  height: 230,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          "$key_moment_uri${keymoments[index].image}",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              : SizedBox.shrink(),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              keymoments[index].imageSubTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          keymoments[index].image != ""
                              ? SizedBox(
                                  height: 25.0,
                                )
                              : SizedBox(
                                  height: 2,
                                ),
                        ],
                      )
                    ],
                  );
                });
          }
        });
  }
}
