import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src_kstu_app/components/colors.dart';
import 'package:src_kstu_app/feature/pages/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamTimetablePage extends StatefulWidget {
  const ExamTimetablePage({super.key});

  @override
  State<ExamTimetablePage> createState() => _ExamTimetablePageState();
}

class _ExamTimetablePageState extends State<ExamTimetablePage> {
  final List<Exam> _allExams = [
    Exam(
      courseCode: 'CS 101',
      courseName: 'Introduction to Computer Science',
      date: DateTime(2023, 12, 4, 9, 0),
      duration: '3 Hours',
      venue: 'Main Auditorium',
      pdfUrl: 'https://example.com/timetables/cs101.pdf',
    ),
    Exam(
      courseCode: 'MATH 201',
      courseName: 'Advanced Calculus',
      date: DateTime(2023, 12, 5, 14, 0),
      duration: '2 Hours',
      venue: 'Block B Room 101',
      pdfUrl: 'https://example.com/timetables/math201.pdf',
    ),
    Exam(
      courseCode: 'ENG 102',
      courseName: 'Technical Writing',
      date: DateTime(2023, 12, 6, 9, 0),
      duration: '2 Hours',
      venue: 'Block A Room 205',
    ),
    Exam(
      courseCode: 'PHY 103',
      courseName: 'Modern Physics',
      date: DateTime(2023, 12, 7, 14, 0),
      duration: '3 Hours',
      venue: 'Physics Lab',
      pdfUrl: 'https://example.com/timetables/phy103.pdf',
    ),
  ];

  List<Exam> _filteredExams = [];
  String _searchQuery = '';
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _filteredExams = _allExams;
  }

  void _filterExams() {
    setState(() {
      _filteredExams = _allExams.where((exam) {
        final matchesSearch = exam.courseCode
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            exam.courseName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDepartment = _selectedDepartment == null ||
            exam.courseCode.startsWith(_selectedDepartment!);
        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  Future<void> _launchPdf(String url) async {
      await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: topColor,
        resizeToAvoidBottomInset: false,
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
                            decoration: BoxDecoration(
                              color: topColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Dashboard(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: bottomColor,
                                          size: 25,
                                        ),
                                      ),
                                      Text(
                                        "Exam Timetable",
                                        style: GoogleFonts.poppins(
                                          color: bottomColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                children: [
                                  _buildSearchFilterRow(),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _filteredExams.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No exams found',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: _filteredExams.length,
                                            itemBuilder: (context, index) {
                                              return _buildExamCard(
                                                  _filteredExams[index]);
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

  Widget _buildSearchFilterRow() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: GoogleFonts.poppins(),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.poppins(),
          onChanged: (value) {
            _searchQuery = value;
            _filterExams();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Filter by Department',
            labelStyle: GoogleFonts.poppins(color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            'All Departments',
            'CS - Computer Science',
            'MATH - Mathematics',
            'ENG - Engineering',
            'PHY - Physics',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value == 'All Departments' ? null : value.split(' - ')[0],
              child: Text(value, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (value) {
            _selectedDepartment = value;
            _filterExams();
          },
          value: _selectedDepartment,
        ),
      ],
    );
  }

  Widget _buildExamCard(Exam exam) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
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
                  exam.courseCode,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (exam.pdfUrl != null)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _launchPdf(exam.pdfUrl!),
                  ),
              ],
            ),
            Text(
              exam.courseName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(exam.date),
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(exam.date),
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${exam.duration}',
                  style: GoogleFonts.poppins(),
                ),
                const Spacer(),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(
                  exam.venue,
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Exam {
  final String courseCode;
  final String courseName;
  final DateTime date;
  final String duration;
  final String venue;
  final String? pdfUrl;

  Exam({
    required this.courseCode,
    required this.courseName,
    required this.date,
    required this.duration,
    required this.venue,
    this.pdfUrl,
  });
}
