import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src_kstu_app/components/colors.dart';
import 'package:src_kstu_app/feature/pages/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  final List<AcademicEvent> _events = [
    AcademicEvent(
      title: "First Semester Begins",
      date: DateTime(2023, 9, 4),
      description: "Commencement of academic activities for first semester",
      pdfUrl: "https://example.com/calendar/sem1-start.pdf",
    ),
    AcademicEvent(
      title: "Mid-Semester Break",
      date: DateTime(2023, 10, 16),
      endDate: DateTime(2023, 10, 20),
      description: "One week break for mid-semester rest",
    ),
    AcademicEvent(
      title: "First Semester Exams",
      date: DateTime(2023, 12, 4),
      endDate: DateTime(2023, 12, 15),
      description: "End of semester examinations",
      pdfUrl: "https://example.com/calendar/sem1-exams.pdf",
    ),
    AcademicEvent(
      title: "Second Semester Begins",
      date: DateTime(2024, 1, 8),
      description: "Commencement of academic activities for second semester",
      pdfUrl: "https://example.com/calendar/sem2-start.pdf",
    ),
    AcademicEvent(
      title: "Long Vacation",
      date: DateTime(2024, 5, 20),
      endDate: DateTime(2024, 8, 31),
      description: "End of academic year vacation period",
    ),
  ];

  Future<void> _launchPdf(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: topColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
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
                      children: [
                        Expanded(
                          child: Container(
                            height: 20,
                            decoration: const BoxDecoration(
                                color: topColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 10),
                              child: Column(children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Dashboard()),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        color: bottomColor,
                                        size: 25,
                                      ),
                                    ),
                                    Text(
                                      "Academic Calendar",
                                      style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          color: bottomColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ]),
                            )),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: bottomColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Academic Year 2023/2024',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _events.length,
                                      itemBuilder: (context, index) {
                                        final event = _events[index];
                                        return _buildEventCard(event);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(AcademicEvent event) {
    final dateFormat = DateFormat('MMM d');
    final endDateFormat = DateFormat('MMM d, y');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: bottomColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (event.pdfUrl != null)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _launchPdf(event.pdfUrl!),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 8),
            Text(
              event.endDate == null
                  ? dateFormat.format(event.date)
                  : '${dateFormat.format(event.date)} - ${endDateFormat.format(event.endDate!)}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicEvent {
  final String title;
  final DateTime date;
  final DateTime? endDate;
  final String description;
  final String? pdfUrl;

  AcademicEvent({
    required this.title,
    required this.date,
    this.endDate,
    required this.description,
    this.pdfUrl,
  });
}