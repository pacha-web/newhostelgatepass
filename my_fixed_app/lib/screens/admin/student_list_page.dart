import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/api/students"));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          students = jsonData.map((json) => Student.fromJson(json)).toList();
          filteredStudents = students;
        });
      } else {
        throw Exception("Failed to load students");
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  void _deleteStudent(int id) async {
    try {
      final response = await http.delete(Uri.parse("http://10.0.2.2:3000/api/students/$id"));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student deleted successfully")),
        );
        fetchStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete student")),
        );
      }
    } catch (e) {
      print("Error deleting student: $e");
    }
  }

  void _searchStudents(String query) {
    final filtered = students.where((student) =>
      student.name.toLowerCase().contains(query.toLowerCase()) ||
      student.department.toLowerCase().contains(query.toLowerCase()) ||
      student.guardianName.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      filteredStudents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student List"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchStudents,
              decoration: const InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(student.name),
                    subtitle: Text("Department: ${student.department}\nPhone: ${student.phone}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStudent(student.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      guardianName: json['guardianName'] ?? '',
      guardianPhone: json['guardianPhone'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}
