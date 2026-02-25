import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: GogomarketCourierApp()));
}

class GogomarketCourierApp extends StatelessWidget {
  const GogomarketCourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOGOMARKET Courier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B894),
        colorScheme: const ColorScheme.light(primary: Color(0xFF00B894)),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const CourierHomeScreen(),
    );
  }
}

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GOGOMARKET Courier'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(child: Text('Available Orders', style: TextStyle(fontSize: 18))),
          Center(child: Text('My Deliveries', style: TextStyle(fontSize: 18))),
          Center(child: Text('Earnings', style: TextStyle(fontSize: 18))),
          Center(child: Text('Profile', style: TextStyle(fontSize: 18))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00B894),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Deliveries'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
