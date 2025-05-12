import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Student> students = [];
  bool isLoading = true;
  String errorMessage = '';

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000'; // for Flutter Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // for Android emulator
    } else {
      return 'http://localhost:3000'; // for iOS or desktop
    }
  }

  // Fetch students from backend
  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse("${getBaseUrl()}/api/students"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          students =
              data.map((studentData) => Student.fromJson(studentData)).toList();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load students. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchStudents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : RefreshIndicator(
                  onRefresh: fetchStudents,
                  child: students.isEmpty
                      ? const Center(child: Text('No students found.'))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            return StudentListTile(student: students[index]);
                          },
                        ),
                ),
    );
  }
}

class StudentListTile extends StatelessWidget {
  final Student student;

  const StudentListTile({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: student.profileImage != null &&
                  student.profileImage!.isNotEmpty
              ? NetworkImage(student.profileImage!)
              : const AssetImage('assets/default-profile.png')
                  as ImageProvider,
        ),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${student.id}"),
            Text("Department: ${student.department}"),
            Text("Phone: ${student.phone}"),
            Text("Email: ${student.email}"),
            Text("Address: ${student.address}"),
            Text("DOB: ${student.dob}"),
            Text("Gender: ${student.gender}"),
            Text("Guardian: ${student.guardianName}"),
            Text("Guardian Phone: ${student.guardianPhone}"),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// Model class
class Student {
  final int id;
  final String name;
  final String department;
  final String phone;
  final String email;
  final String address;
  final String dob;
  final String gender;
  final String guardianName;
  final String guardianPhone;
  final String? profileImage;

  Student({
    required this.id,
    required this.name,
    required this.department,
    required this.phone,
    required this.email,
    required this.address,
    required this.dob,
    required this.gender,
    required this.guardianName,
    required this.guardianPhone,
    this.profileImage,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      dob: json['dob'],
      gender: json['gender'],
      guardianName: json['guardianName'],
      guardianPhone: json['guardianPhone'],
      profileImage: json['profileImage'],
    );
  }
}
