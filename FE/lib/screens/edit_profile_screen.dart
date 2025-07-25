import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _ageController;
  List<String> _interests = [];
  final TextEditingController _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _interests = List.from(user?.interests ?? []);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF7),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFAF7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.27,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF9C854A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8C4A0),
                      ),
                      child: ClipOval(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF9C854A),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Full Name
              _buildInputField(
                'Full Name',
                _fullNameController,
                'Enter your full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Bio
              _buildInputField(
                'Bio',
                _bioController,
                'Tell us about yourself',
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // Age
              _buildInputField(
                'Age',
                _ageController,
                'Enter your age',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // City
              _buildInputField(
                'City',
                _cityController,
                'Enter your city',
              ),
              SizedBox(height: 20),

              // Country
              _buildInputField(
                'Country',
                _countryController,
                'Enter your country',
              ),
              SizedBox(height: 20),

              // Interests Section
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              
              // Add Interest Field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestController,
                      decoration: InputDecoration(
                        hintText: 'Add an interest',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xffe8e0cf)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xffe8e0cf)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9C854A)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF9C854A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _addInterest,
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Interest Chips
              if (_interests.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests.map((interest) => Chip(
                    label: Text(interest),
                    backgroundColor: Color(0xFFE8C4A0),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () => _removeInterest(interest),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffe8e0cf)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xffe8e0cf)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF9C854A)),
            ),
          ),
        ),
      ],
    );
  }

  void _addInterest() {
    if (_interestController.text.isNotEmpty) {
      setState(() {
        _interests.add(_interestController.text.trim());
        _interestController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save profile logic with backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF9C854A),
        ),
      );
      Navigator.pop(context);
    }
  }
}
