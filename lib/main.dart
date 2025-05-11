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
        '/third': (context) => const ChatBotPage(),
        '/fourth': (context) => const Feedback(),
        '/fifth': (context) => const Settings(),
        '/sixth': (context) => const Profile(),
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
  bool isLoading = false;
  bool isPasswordVisible = false;

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

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
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

  bool isEmail(String input) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input);
  }

  bool isStrongPassword(String input) {
    return input.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username (email format)",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String user = usernameController.text;
                      String pass = passwordController.text;

                      if (!isEmail(user)) {
                        showAlertDialog('Please enter a valid email address.');
                        return;
                      }
                      if (!isStrongPassword(pass)) {
                        showAlertDialog('Password must be at least 6 characters.');
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      bool isValid = await validateLogin(user, pass);
                      setState(() {
                        isLoading = false;
                      });

                      if (isValid) {
                        if (rememberMe) {
                          await saveLoginData(user, pass);
                        }
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      } else {
                        showAlertDialog('Invalid username or password');
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String user = usernameController.text;
                      String pass = passwordController.text;

                      if (!isEmail(user)) {
                        showAlertDialog('Please enter a valid email address.');
                        return;
                      }
                      if (!isStrongPassword(pass)) {
                        showAlertDialog('Password must be at least 6 characters.');
                        return;
                      }

                      await saveLoginData(user, pass);
                      showAlertDialog("Account Created. Now log in.");
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color.fromARGB(255, 127, 195, 236),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 55, 150, 191),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 6, 33, 79)),
              child: Text('child care', style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/third'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.white),
              title: const Text('Feedback', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/fourth'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/fifth'),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile/Login', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/sixth'),
            ),
            ListTile(
              leading: const Icon(Icons.message_rounded, color: Colors.white),
              title: const Text('Chat Bot', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/third'),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Autism Early Detection App',
              style: TextStyle(
                color: Color.fromARGB(255, 43, 153, 161),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Helping parents assess developmental milestones in children',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 21, 0, 70),
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _profileImage;
  File? _videoFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    final name = nameController.text;
    final age = ageController.text;
    final address = addressController.text;
    final phone = phoneController.text;

    // Save these to Firebase or local DB if required

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Child's Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file),
              label: const Text('Upload Observation Video'),
            ),
            if (_videoFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child:
                    Text('Selected Video: ${_videoFile!.path.split('/').last}'),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: Colors.purple.shade800,
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _buildSection("Accessibility Settings", [
              "Text Size & Font Choice",
              "High Contrast Mode / Dark Mode",
              "Sound Control (Mute, Volume Adjustments)",
              "Animation Toggle",
              "Haptic Feedback Control",
              "Speech Output Speed & Tone"
            ]),
            _buildSection("Learning Customization", [
              "Preferred Learning Style Selector",
              "Task Difficulty Adjustment",
              "Repetition Settings",
              "Progression Control"
            ]),
            _buildSection("Notifications & Reminders", [
              "Routine Reminders",
              "Session Time Limits",
              "Event Reminders"
            ]),
            _buildSection("Parental Controls & Security", [
              "PIN Protection",
              "Content Access Control",
              "Data Sharing Consent",
              "Profile Switching Lock"
            ]),
            _buildSection("Progress & Reports", [
              "Enable/Disable Progress Tracking",
              "Export Reports",
              "Sync with Therapist/Educator"
            ]),
            _buildSection("Language & Regional Settings", [
              "Language Selection",
              "Voice Language Options",
              "Date & Time Format"
            ]),
            _buildSection("App Customization", [
              "Theme Selection",
              "Custom Avatar Builder",
              "Custom Rewards System"
            ]),
            _buildSection("Support & Help", [
              "How-To Tutorials",
              "FAQs",
              "Contact Support",
              "Report an Issue"
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: items
          .map((item) => ListTile(
                title: Text(item),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Placeholder for future individual setting screens
                },
              ))
          .toList(),
    );
  }
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