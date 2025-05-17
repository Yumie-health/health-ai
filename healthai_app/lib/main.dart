import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the color palette
const Color kPrimaryGreen = Color(0xFF4CAF50); // Soft green
const Color kAccentOrange = Color(0xFFFFA726); // Bright orange
const Color kAccentYellow = Color(0xFFFFEB3B); // Bright yellow
const Color kSecondaryBlue = Color(0xFF2196F3); // Cool blue
const Color kBackgroundWhite = Color(0xFFFFFFFF); // Clean white
const Color kWarningRed = Color(0xFFFF7043); // Orange/Red for warnings
const Color kContainerGrey = Color(0xFFF5F5F5); // Light grey for containers

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthAI App',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryGreen,
          onPrimary: Colors.white,
          secondary: kSecondaryBlue,
          onSecondary: Colors.white,
          error: kWarningRed,
          onError: Colors.white,
          surface: kContainerGrey,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: kBackgroundWhite,
        appBarTheme: AppBarTheme(
          backgroundColor: kPrimaryGreen,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kSecondaryBlue,
            side: BorderSide(color: kSecondaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kContainerGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kPrimaryGreen, width: 2),
          ),
          labelStyle: TextStyle(color: kPrimaryGreen),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return MainNavScreen();
          }
          return AuthScreen();
        },
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        // Add more user fields as needed
      });
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        print(userDoc.data());
      }
      setState(() => message = 'Sign in successful!');
    } catch (e) {
      setState(() => message = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        // Add more user fields as needed
      });
      setState(() => message = 'Sign up successful!');
    } catch (e) {
      setState(() => message = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kContainerGrey,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or title
                Icon(Icons.health_and_safety, size: 72, color: kPrimaryGreen),
                const SizedBox(height: 16),
                Text(
                  'Welcome to HealthAI',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Email field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: kPrimaryGreen),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: kPrimaryGreen),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Buttons
                isLoading
                    ? const CircularProgressIndicator(color: kPrimaryGreen)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSecondaryBlue,
                            ),
                            child: const Text('Sign In'),
                          ),
                          OutlinedButton(
                            onPressed: signUp,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kAccentOrange,
                              side: const BorderSide(color: kAccentOrange, width: 2),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                // Message area
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: message.startsWith('Error')
                          ? kWarningRed
                          : kPrimaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FoodLogForm extends StatefulWidget {
  const FoodLogForm({super.key});

  @override
  _FoodLogFormState createState() => _FoodLogFormState();
}

class _FoodLogFormState extends State<FoodLogForm> {
  final TextEditingController foodController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  String message = '';

  Future<void> addFoodLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => message = 'Please sign in first.');
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .add({
        'food': foodController.text.trim(),
        'calories': int.tryParse(caloriesController.text) ?? 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        message = 'Food log added!';
        foodController.clear();
        caloriesController.clear();
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Text('Add Food Log', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
        const SizedBox(height: 8),
        TextField(
          controller: foodController,
          decoration: const InputDecoration(labelText: 'Food Name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: caloriesController,
          decoration: const InputDecoration(labelText: 'Calories'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: addFoodLog,
          child: const Text('Add Log'),
        ),
        if (message.isNotEmpty)
          Text(
            message,
            style: TextStyle(
              color: message.startsWith('Error') ? kWarningRed : kPrimaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class FoodLogList extends StatelessWidget {
  const FoodLogList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Text('Please sign in.');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Text('No food logs yet.');
        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['food'] ?? ''),
              subtitle: Text('Calories: ${data['calories'] ?? 0}'),
              trailing: Text(
                data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                    : '',
              ),
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthAI - Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FoodLogForm(),
            const SizedBox(height: 16),
            FoodLogList(),
          ],
        ),
      ),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    ScanScreen(),
    LogScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kPrimaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: kBackgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: kContainerGrey,
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today's Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Summary",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Row(
                      children: [
                        Text(
                          'May 16, 2025',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryBox(
                      icon: Icons.restaurant,
                      color: kPrimaryGreen.withOpacity(0.12),
                      label: 'Food',
                      value: '1,245',
                      valueColor: kPrimaryGreen,
                    ),
                    _SummaryBox(
                      icon: Icons.favorite_border,
                      color: kSecondaryBlue.withOpacity(0.12),
                      label: 'Activity',
                      value: '320',
                      valueColor: kSecondaryBlue,
                    ),
                    _SummaryBox(
                      icon: Icons.cookie,
                      color: kAccentOrange.withOpacity(0.12),
                      label: 'Remaining',
                      value: '635',
                      valueColor: kAccentOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ProgressRow(label: 'Daily Goal', value: '1,245 / 2,200 cal', percent: 1245/2200),
                _ProgressRow(label: 'Protein', value: '42 / 120 g', percent: 42/120),
                _ProgressRow(label: 'Carbs', value: '145 / 250 g', percent: 145/250),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // AI Insight Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSecondaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights, color: kSecondaryBlue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('AI Insight', style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryBlue)),
                      SizedBox(height: 4),
                      Text(
                        "You're 15% under your protein goal this week. Adding Greek yogurt or lean chicken to your next meal would help balance your macros.",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Today's Meals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Meals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
          _MealCard(
            meal: 'Breakfast',
            calories: 320,
            foods: ['Oatmeal with blueberries'],
            iconColor: kPrimaryGreen.withOpacity(0.12),
            icon: Icons.restaurant,
          ),
          _MealCard(
            meal: 'Lunch',
            calories: 450,
            foods: ['Grilled chicken salad'],
            iconColor: kSecondaryBlue.withOpacity(0.12),
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('+ Add Meal', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color valueColor;
  const _SummaryBox({required this.icon, required this.color, required this.label, required this.value, required this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: valueColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  const _ProgressRow({required this.label, required this.value, required this.percent});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: kContainerGrey,
              color: kPrimaryGreen,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String meal;
  final int calories;
  final List<String> foods;
  final Color iconColor;
  final IconData icon;
  const _MealCard({required this.meal, required this.calories, required this.foods, required this.iconColor, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: kPrimaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...foods.map((f) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(f, style: const TextStyle(color: Colors.black87)),
                )),
              ],
            ),
          ),
          Text('$calories cal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Food', style: TextStyle(color: Colors.black)),
        backgroundColor: kBackgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: kContainerGrey,
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Scan Your Food', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: kContainerGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 36,
                    child: Icon(Icons.camera_alt, color: Colors.grey[500], size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text('Point camera at food to analyze', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kSecondaryBlue,
                    side: BorderSide(color: kSecondaryBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSecondaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: kSecondaryBlue),
                    SizedBox(width: 8),
                    Text('Scanning Tips', style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryBlue)),
                  ],
                ),
                const SizedBox(height: 12),
                _ScanTip(number: 1, text: 'Place food on a plain background for better results'),
                _ScanTip(number: 2, text: 'Make sure there\'s good lighting'),
                _ScanTip(number: 3, text: 'Position camera 8-12 inches from food'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanTip extends StatelessWidget {
  final int number;
  final String text;
  const _ScanTip({required this.number, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: kSecondaryBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: const TextStyle(color: kSecondaryBlue, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Log', style: TextStyle(color: Colors.black)),
        backgroundColor: kBackgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: kContainerGrey,
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar and filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search foods...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: kContainerGrey,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: kContainerGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Date and section title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Meals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Text('May 16, 2025', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 4),
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Meal cards
          _LogMealCard(
            meal: 'Breakfast',
            time: '8:30 AM',
            calories: 325,
            macros: 'P: 12g • C: 59g • F: 6g',
            foods: [
              _LogFoodItem(name: 'Oatmeal with blueberries', calories: 320, macros: 'P: 12g • C: 58g • F: 6g'),
              _LogFoodItem(name: 'Black coffee', calories: 5, macros: 'P: 0g • C: 1g • F: 0g'),
            ],
          ),
          _LogMealCard(
            meal: 'Lunch',
            time: '12:45 PM',
            calories: 450,
            macros: 'P: 32g • C: 25g • F: 22g',
            foods: [
              _LogFoodItem(name: 'Grilled chicken salad', calories: 450, macros: 'P: 32g • C: 25g • F: 22g'),
              _LogFoodItem(name: 'Sparkling water', calories: 0, macros: 'P: 0g • C: 0g • F: 0g'),
            ],
          ),
          _LogMealCard(
            meal: 'Snack',
            time: '3:15 PM',
            calories: 215,
            macros: 'P: 15g • C: 32g • F: 0g',
            foods: [
              _LogFoodItem(name: 'Greek yogurt', calories: 120, macros: 'P: 15g • C: 7g • F: 0g'),
              _LogFoodItem(name: 'Apple', calories: 95, macros: 'P: 0g • C: 25g • F: 0g'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('+ Add Meal', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogMealCard extends StatelessWidget {
  final String meal;
  final String time;
  final int calories;
  final String macros;
  final List<_LogFoodItem> foods;
  const _LogMealCard({required this.meal, required this.time, required this.calories, required this.macros, required this.foods});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$calories cal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(macros, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Divider(height: 18),
          ...foods,
        ],
      ),
    );
  }
}

class _LogFoodItem extends StatelessWidget {
  final String name;
  final int calories;
  final String macros;
  const _LogFoodItem({required this.name, required this.calories, required this.macros});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: kPrimaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(macros, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text('$calories cal', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: kBackgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: kContainerGrey,
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: kContainerGrey,
                      child: Icon(Icons.person, color: kSecondaryBlue, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 2),
                          Text('john.doe@example.com', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ProfileStatBox(label: '28', sublabel: 'Age', color: kPrimaryGreen.withOpacity(0.12), valueColor: kPrimaryGreen),
                    _ProfileStatBox(label: '175cm', sublabel: 'Height', color: kSecondaryBlue.withOpacity(0.12), valueColor: kSecondaryBlue),
                    _ProfileStatBox(label: '72kg', sublabel: 'Weight', color: kAccentOrange.withOpacity(0.12), valueColor: kAccentOrange),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kSecondaryBlue,
                      side: BorderSide(color: kSecondaryBlue, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Weekly Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _ProfileProgressRow(
                  icon: Icons.bar_chart,
                  label: 'Calories',
                  value: '1,870 avg/day',
                  percent: 0.85,
                  color: kPrimaryGreen,
                  barColor: kPrimaryGreen,
                  secondaryBarColor: kSecondaryBlue,
                ),
                _ProfileProgressRow(
                  icon: Icons.favorite_border,
                  label: 'Exercise',
                  value: '4 days',
                  percent: 0.6,
                  color: kSecondaryBlue,
                  barColor: kSecondaryBlue,
                  secondaryBarColor: kPrimaryGreen,
                ),
                _ProfileProgressRow(
                  icon: Icons.show_chart,
                  label: 'Protein Goal',
                  value: '79%',
                  percent: 0.79,
                  color: kAccentOrange,
                  barColor: kPrimaryGreen,
                  secondaryBarColor: kSecondaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _ProfileSettingTile(icon: Icons.settings, label: 'Preferences', onTap: () {}),
                _ProfileSettingTile(icon: Icons.favorite, label: 'Health Goals', onTap: () {}),
                _ProfileSettingTile(icon: Icons.bar_chart, label: 'Nutrition Plan', onTap: () {}),
                _ProfileSettingTile(icon: Icons.person, label: 'Account', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              style: TextButton.styleFrom(foregroundColor: kWarningRed),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final Color valueColor;
  const _ProfileStatBox({required this.label, required this.sublabel, required this.color, required this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(sublabel, style: TextStyle(color: valueColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double percent;
  final Color color;
  final Color barColor;
  final Color secondaryBarColor;
  const _ProfileProgressRow({required this.icon, required this.label, required this.value, required this.percent, required this.color, required this.barColor, required this.secondaryBarColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: secondaryBarColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 10,
                  width: percent.clamp(0.0, 1.0) * MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileSettingTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kSecondaryBlue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
