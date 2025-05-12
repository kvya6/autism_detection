import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/second': (context) => const GamePage(),
        '/third': (context) => const ChatBotPage(),
        '/sixth': (context) => const Feedback(),
        '/fifth': (context) => const Settings(),
        '/fourth': (context) => const Profile(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('rememberMe') == true &&
        prefs.getString('username') != null &&
        prefs.getString('password') != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> saveLoginData(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', rememberMe);
  }

  Future<bool> validateLogin(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    String? storedPassword = prefs.getString('password');
    return (storedUsername == username && storedPassword == password);
  }

  bool isEmailOrPhone(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final phoneRegex = RegExp(r'^\d{10}$');
    return emailRegex.hasMatch(input) || phoneRegex.hasMatch(input);
  }

  bool isStrongPassword(String input) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(input);
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Info"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void forgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: const Text("Please contact support to reset your password."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(color: Colors.black.withOpacity(0.6)),
          // Login form
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white.withOpacity(0.7), // Make the card background transparent
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          "Login to Your Account",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: "Email or Phone",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                const Text("Remember Me"),
                              ],
                            ),
                            TextButton(
                              onPressed: forgotPasswordDialog,
                              child: const Text("Forgot Password?"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            String user = usernameController.text.trim();
                            String pass = passwordController.text.trim();

                            if (!isEmailOrPhone(user)) {
                              showAlertDialog("Enter a valid email or 10-digit phone number.");
                              return;
                            }
                            if (!isStrongPassword(pass)) {
                              showAlertDialog(
                                  "Password must be at least 8 characters,\ninclude uppercase, number, and symbol.");
                              return;
                            }

                            setState(() => isLoading = true);
                            bool isValid = await validateLogin(user, pass);
                            setState(() => isLoading = false);

                            if (isValid) {
                              if (rememberMe) {
                                await saveLoginData(user, pass);
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomePage()),
                              );
                            } else {
                              showAlertDialog("Invalid username or password.");
                            }
                          },
                          icon: const Icon(Icons.login),
                          label: const Text("Login"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 44, 100, 179),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        OutlinedButton(
                          onPressed: () async {
                            String user = usernameController.text.trim();
                            String pass = passwordController.text.trim();

                            if (!isEmailOrPhone(user)) {
                              showAlertDialog("Enter a valid email or 10-digit phone number.");
                              return;
                            }

                            if (!isStrongPassword(pass)) {
                              showAlertDialog(
                                  "Password must be at least 8 characters,\ninclude uppercase, number, and symbol.");
                              return;
                            }

                            await saveLoginData(user, pass);
                            showAlertDialog("Account Created. Now log in.");
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 39, 114, 176),
                            side: const BorderSide(color: Color.fromARGB(255, 39, 128, 176)),
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: Colors.lightBlue.shade100,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 6, 33, 79)),
              child: Text('Child Care', style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blueGrey),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueGrey),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/fourth'),
            ),
            ListTile(
              leading: const Icon(Icons.message_rounded, color: Colors.blueGrey),
              title: const Text('Chat Bot'),
              onTap: () => Navigator.pushNamed(context, '/third'),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset, color: Colors.blueGrey),
              title: const Text('Game'),
              onTap: () => Navigator.pushNamed(context, '/second'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/fifth'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.blueGrey),
              title: const Text('Feedback'),
              onTap: () => Navigator.pushNamed(context, '/sixth'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animation/child_care.json',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Autism Early Detection App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Helping parents assess developmental milestones in children',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black38,
                        offset: Offset(1, 1),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<Profile> {
  // Controllers for the profile fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalConditionsController = TextEditingController();
  final TextEditingController currentMedicationsController = TextEditingController();
  final TextEditingController immunizationStatusController = TextEditingController();
  final TextEditingController familyDoctorController = TextEditingController();
  final TextEditingController therapistContactController = TextEditingController();

  File? _profileImage;
  File? _videoFile;

  String selectedHeightUnit = 'cm';  // Options for height unit
  String selectedWeightUnit = 'kg';  // Options for weight unit

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to pick a video from the gallery
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  // Function to save the profile data
  void _saveProfile() {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final dob = dobController.text;
    final gender = genderController.text;
    final parentName = parentNameController.text;
    final phone = phoneController.text;
    final email = emailController.text;
    final address = '${streetController.text}, ${cityController.text}, ${stateController.text}, ${zipController.text}';
    final emergencyContact = emergencyContactController.text;
    final height = heightController.text;
    final weight = weightController.text;
    final bloodGroup = bloodGroupController.text;
    final allergies = allergiesController.text;
    final medicalConditions = medicalConditionsController.text;
    final currentMedications = currentMedicationsController.text;
    final immunizationStatus = immunizationStatusController.text;
    final familyDoctor = familyDoctorController.text;
    final therapistContact = therapistContactController.text;

    // Save these to Firebase or local DB if required

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

  // Function to handle logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Profile_Background.jpg'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              // First Name and Last Name on the same line
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(firstNameController, 'First Name'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(lastNameController, 'Last Name'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(dobController, 'Date of Birth / Age'),
              _buildTextField(genderController, 'Gender'),
              _buildTextField(parentNameController, 'Parent/Guardian Name'),
              _buildPhoneNumberField(),
              _buildTextField(emailController, 'Email Address'),
              const SizedBox(height: 20),
              // Address section
              _buildTextField(streetController, 'Street Address'),
              _buildTextField(cityController, 'City'),
              _buildTextField(stateController, 'State'),
              _buildTextField(zipController, 'ZIP Code'),
              const SizedBox(height: 20),
              _buildTextField(emergencyContactController, 'Emergency Contact(s)'),
              // Height and Weight on the same line
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(heightController, 'Height', TextInputType.number),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildUnitSelector('Height Unit', selectedHeightUnit, ['cm', 'm']),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(weightController, 'Weight', TextInputType.number),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildUnitSelector('Weight Unit', selectedWeightUnit, ['kg', 'lbs']),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(bloodGroupController, 'Blood Group'),
              _buildTextField(allergiesController, 'Allergies'),
              _buildTextField(medicalConditionsController, 'Medical Conditions'),
              _buildTextField(currentMedicationsController, 'Current Medications'),
              _buildTextField(immunizationStatusController, 'Immunization Status'),
              _buildTextField(familyDoctorController, 'Family Doctor Contact'),
              _buildTextField(therapistContactController, 'Therapist Contact Info'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_file),
                label: const Text('Upload Observation Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(94, 154, 180, 1), // Light blue theme
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
              if (_videoFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Selected Video: ${_videoFile!.path.split('/').last}'),
                ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(94, 154, 180, 1), // Light blue theme
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red for logout
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create a text field
  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent, // Transparent background for fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
          ),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        style: TextStyle(color: Colors.white), // White text inside the fields
        keyboardType: keyboardType,
      ),
    );
  }

  // Helper function for phone number input
  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
                ),
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              maxLength: 10, // Limiting to 10 digits
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create unit selectors for height and weight
  Widget _buildUnitSelector(String label, String selectedValue, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6), width: 1),
          ),
          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7)),
        ),
        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        items: options.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            if (label == 'Height Unit') {
              selectedHeightUnit = newValue!;
            } else if (label == 'Weight Unit') {
              selectedWeightUnit = newValue!;
            }
          });
        },
      ),
    );
  }
}



class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<_SettingSection> sections = [
    _SettingSection("Accessibility", Icons.accessibility_new_rounded, [
      "Text Size & Font Choice",
      "High Contrast / Dark Mode",
      "Sound Control",
      "Animation Toggle",
      "Haptic Feedback",
      "Speech Output"
    ]),
    _SettingSection("Notifications", Icons.notifications_active, [
      "Routine Reminders",
      "Session Limits",
      "Event Reminders"
    ]),
    _SettingSection("Parental Controls", Icons.lock_person, [
      "PIN Protection",
      "Content Control",
      "Data Consent",
      "Profile Lock"
    ]),
    _SettingSection("Progress & Reports", Icons.bar_chart_rounded, [
      "Track Progress",
      "Export Reports",
      "Sync with Therapist"
    ]),
    _SettingSection("Language & Region", Icons.language, [
      "Language Selection",
      "Voice Options",
      "Date & Time Format"
    ]),
    _SettingSection("App Customization", Icons.format_paint, [
      "Theme Selection",
      "Avatar Builder",
      "Rewards System"
    ]),
    _SettingSection("Support & Help", Icons.help_outline, [
      "Tutorials",
      "FAQs",
      "Contact Support",
      "Report Issue"
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade700,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: ExpansionTile(
              leading: Icon(section.icon, color: Colors.lightBlue.shade700),
              title: Text(
                section.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
              ),
              children: section.items
                  .map((item) => ListTile(
                        title: Text(item, style: TextStyle(color: Colors.blueGrey.shade700)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Placeholder for setting detail navigation
                        },
                      ))
                  .toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade700,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.home, color: Colors.white),
          label: const Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _SettingSection {
  final String title;
  final IconData icon;
  final List<String> items;

  _SettingSection(this.title, this.icon, this.items);
}

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];

  final Map<String, String> autismResponses = {
    'meltdown': 'Meltdowns can be overwhelming. Support includes giving space, reducing sensory input, and providing calming objects like weighted blankets.',
    'routine': 'Routines help individuals with autism feel safe and in control. Try creating visual schedules or consistent daily plans.',
    'sensory': 'Sensory sensitivities are common. You can help by identifying triggers (e.g., loud sounds, bright lights) and creating a calm environment.',
    'communication': 'Using AAC tools, visual aids, or sign language can support nonverbal individuals. Patience and consistency are key.',
    'social skills': 'Social skills can be taught using role play, social stories, or therapy like ABA or speech therapy.',
  };

  Future<void> _generateResponse(String userInput) async {
    setState(() {
      _chatMessages.add({'role': 'user', 'content': userInput});
    });

    String responseText = '';
    for (var entry in autismResponses.entries) {
      if (userInput.toLowerCase().contains(entry.key.toLowerCase())) {
        responseText += '${entry.value}\n\n';
      }
    }

    if (responseText.isNotEmpty) {
      setState(() {
        _chatMessages.add({'role': 'assistant', 'content': responseText.trim()});
      });
      return;
    }

    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': 'Error: API key not set. Please check your .env file.'
        });
      });
      return;
    }

    List<Map<String, String>> messages = [
      {
        "role": "system",
        "content":
            "You are an autism support assistant. Provide compassionate, accurate answers to questions about autism spectrum disorder, including behavioral strategies, sensory sensitivities, communication methods, and caregiver tips."
      },
      {"role": "user", "content": userInput},
    ];

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _chatMessages.add({
            'role': 'assistant',
            'content': data['choices'][0]['message']['content'].trim()
          });
        });
      } else {
        setState(() {
          _chatMessages.add({
            'role': 'assistant',
            'content': 'Error: Unable to generate response. Please try again later.'
          });
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add({'role': 'assistant', 'content': 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Autism Support Bot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    final isUser = message['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.teal[200] : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message['content'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask something about autism...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            _generateResponse(_controller.text);
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Addpage extends StatefulWidget {
  const Addpage({super.key});

  @override
  State<Addpage> createState() => _AddpageState();
}

class _AddpageState extends State<Addpage> {
  var tablet = TextEditingController();
  var message = TextEditingController();
  var tab1, msg1, date1, time1;
  DateTime d1 = DateTime.now();
  TimeOfDay t1 = TimeOfDay.now();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone data and set the local timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('(UTC +05:30) Chennai, Kolkata, Mumbai, New Delhi')); // Replace with your timezone
  }

  Future<void> _scheduleNotification(DateTime dateTime) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Ensure the sound file exists in the `res/raw` folder
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Reminder',
      'It\'s time for your scheduled reminder!',
      tz.TZDateTime.from(dateTime, tz.local), // tz.local is now properly initialized
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
    );

    // Optionally play the notification sound immediately
    playNotificationSound();
  }

  // Function to play sound immediately using the audioplayers package
  Future<void> playNotificationSound() async {
    AudioPlayer audioPlayer = AudioPlayer();
    AudioCache audioCache = AudioCache();
await audioCache.play('assets/notification-19-270138.mp3');

  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((onValue) => {
      if (onValue != null) {setState(() => d1 = onValue)}
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((onValue) => {
      if (onValue != null) {setState(() => t1 = onValue)}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.alarm,
          size: 50,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.amber.shade900,
        title: const Text(
          'Add Reminder',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        alignment: Alignment.topLeft,
        color: Colors.amber.shade50,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelField('Tablet', tablet, 'Ex: Paracetemol', icon: Icons.medication),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelField('Message', message, 'Ex: Mix With Water', icon: Icons.message),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPickerField('Time', 'Choose Time', _showTimePicker),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPickerField('Date', 'Choose Date', _showDatePicker),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton('Add', Colors.green, () {
                  String tab1 = tablet.text.toString();
                  String msg1 = message.text.toString();
                  String date1 = d1.toString();
                  String time1 = t1.toString();

                  DateTime scheduledDateTime = DateTime(
                    d1.year,
                    d1.month,
                    d1.day,
                    t1.hour,
                    t1.minute,
                  );

                  _scheduleNotification(scheduledDateTime);

                  // Navigate back to HomePage and pass the entered details
                  Navigator.pop(context, {
                    'tablet': tab1,
                    'message': msg1,
                    'date': date1,
                    'time': time1,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Reminder Scheduled Successfully!'),
                  ));
                }),
                _buildActionButton('Cancel', Colors.red, () {
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to HomePage and pass the entered data
                Navigator.pop(context, {
                  'tablet': tablet.text,
                  'message': message.text,
                  'date': d1.toString(),
                  'time': t1.toString(),
                });
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField(String label, TextEditingController controller, String hintText, {IconData? icon}) {
    return Row(
      children: [
        _buildLabel(label),
        Container(
          margin: const EdgeInsets.all(15),
          width: 300,
          height: 50,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixText: hintText,
              prefixIcon: icon != null ? Icon(icon) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Container(
      width: 200,
      height: 50,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.amber.shade400,
        border: Border.all(
          color: Colors.white,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPickerField(String label, String buttonText, VoidCallback onTap) {
    return Row(
      children: [
        _buildLabel(label),
        Container(
          width: 300,
          height: 50,
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 106, 106, 106),
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: MaterialButton(
            onPressed: onTap,
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.white,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class Feedback extends StatelessWidget {
  const Feedback({super.key});

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Icon(Icons.handshake, color: Colors.purple, size: 50),
              content: const Text(
                'Thanks for your valuable feedback',
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Colors.purple),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.purple,
          textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 18, color: Colors.black87)),
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Feedback'),
              backgroundColor: Colors.purple.shade800,
              centerTitle: true,
            ),
            body: Center(
                child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingBar.builder(
                        itemCount: 5,
                        initialRating: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 5),
                        direction: Axis.horizontal,
                        minRating: 1,
                        itemSize: 50,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return const Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return const Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return const Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return const Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.greenAccent,
                              );
                            case 4:
                              return const Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                            default:
                              return const Text('');
                          }
                        },
                        onRatingUpdate: (rating) {
                          print('Rating: $rating');
                        }),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        minLines: 3,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter your feedback',
                          hintStyle: const TextStyle(fontSize: 16),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade800,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              showAlertDialog(context);
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade800,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ))));
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _score = 0;
  bool _isGameStarted = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _isGameStarted = true;
    });
  }

  void _increaseScore() {
    if (_isGameStarted) {
      setState(() {
        _score++;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _isGameStarted = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tap Score Game',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 5,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/game_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isGameStarted ? 'Score: $_score' : 'Tap to Start the Game',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isGameStarted ? Colors.black87 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isGameStarted ? _increaseScore : _startGame,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.indigoAccent,
                  child: Icon(
                    _isGameStarted ? Icons.touch_app : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isGameStarted)
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}