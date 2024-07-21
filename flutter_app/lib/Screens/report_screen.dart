import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _idController = TextEditingController(); // Changed to _idController
  File? _image;
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final String description = _descriptionController.text;
      final File? photo = _image;

      // Prepare the request
      var uri = Uri.parse('https://your-api-url.com/api/dengue-reports'); // Update this URL
      var request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['user_id'] = '1'; // Replace with actual user ID
      request.fields['description'] = description;
      request.fields['latitude'] = '0.0'; // Replace with actual latitude
      request.fields['longitude'] = '0.0'; // Replace with actual longitude

      // Add photo
      if (photo != null) {
        var photoStream = http.ByteStream(photo.openRead());
        var photoLength = await photo.length();
        var photoFile = http.MultipartFile('photo', photoStream, photoLength, filename: basename(photo.path));
        request.files.add(photoFile);
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
        });
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Failed to submit report.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Dengue Case'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController, // Changed to _idController
                decoration: InputDecoration(
                  labelText: 'ID Number', // Updated label
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ID number';
                  }
                  // Add additional validation if necessary, e.g., check if the ID number is numeric
                  return null;
                },
                keyboardType: TextInputType.number, // Assuming ID is numeric
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 5,
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReport,
                child: Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
