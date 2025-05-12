import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http; // Add this import for HTTP requests
import 'package:cross_file/cross_file.dart';
 // Needed for XFile
class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  File? _profileImage;
  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _departmentController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Pick and compress image
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedFile = await _compressImage(File(pickedFile.path));
      setState(() {
        _profileImage = compressedFile;
      });
    }
  }

  // Compress image
 Future<File> _compressImage(File file) async {
  final XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    file.path.replaceAll(RegExp(r'\.jpg$'), '_compressed.jpg'),
    quality: 80,
  );
  if (result == null) throw Exception('Image compression failed');
  return File(result.path); // ✅ Convert XFile to File
}

  // Submit form to backend
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

   var uri = Uri.parse("http://10.0.2.2:3000/api/students");

    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = _nameController.text;
    request.fields['dob'] = _dobController.text;
    request.fields['department'] = _departmentController.text;
    request.fields['address'] = _addressController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['fatherName'] = _fatherNameController.text;
    request.fields['motherName'] = _motherNameController.text;
    request.fields['username'] = _usernameController.text;
    request.fields['password'] = _passwordController.text;

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        _profileImage!.path,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student successfully added!')),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add student.')),
      );
    }
  }

  // Clear form fields
  void _clearForm() {
    _nameController.clear();
    _dobController.clear();
    _departmentController.clear();
    _addressController.clear();
    _phoneController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _profileImage = null;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Student")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Text fields
              _buildTextField(_nameController, "Name"),
              _buildTextField(_dobController, "Date of Birth (YYYY-MM-DD)"),
              _buildTextField(_departmentController, "Department"),
              _buildTextField(_addressController, "Address"),
              _buildTextField(
                _phoneController,
                "Phone Number",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(_fatherNameController, "Father's Name"),
              _buildTextField(_motherNameController, "Mother's Name"),
              _buildTextField(_usernameController, "Username"),
              _buildTextField(
                _passwordController,
                "Password",
                obscureText: true,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Add Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required.";
          }
          return null;
        },
      ),
    );
  }
}
