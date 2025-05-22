import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _fullName = 'User';

  final List<Widget> _pages = [
    const _HomeContent(),
    const _DummyPage(title: 'Profile'),
    const _DummyPage(title: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _loadFullName();
  }

  Future<void> _loadFullName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = doc['full_name'] ?? 'User';
      setState(() => _fullName = name);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Column(
        children: [
          // ✅ Accent Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: const BoxDecoration(
              color: Constants.accentColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 👤 Welcome Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, $_fullName 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      const SizedBox(height: 4),
                      const Text('Manage your attendance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
                // 🚪 Logout
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    GoRouter.of(context).go('/login');
                  },
                ),
              ],
            ),
          ),

          // 🔽 Main Page Content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Constants.accentColor,
        unselectedItemColor: Constants.accentColor.withOpacity(0.5),
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
        children: [
          _HomeCard(
            label: 'Scan Face',
            icon: Icons.camera_alt_outlined,
            onTap: () => GoRouter.of(context).push('/face-scan'),
          ),
          _HomeCard(
            label: 'My History',
            icon: Icons.history,
            onTap: () => GoRouter.of(context).push('/attendance-history'),
          ),
          _HomeCard(
            label: 'Face Enroll',
            icon: Icons.face_retouching_natural,
            onTap: () => GoRouter.of(context).push('/face-enroll'),
          ),
          _HomeCard(
            label: 'Face Compare',
            icon: Icons.compare_rounded,
            onTap: () => GoRouter.of(context).push('/face-compare'),
          ),
          _HomeCard(
            label: 'Support',
            icon: Icons.help_outline,
            onTap: () {}, // Optional future support
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Constants.accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Constants.accentColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Constants.accentColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DummyPage extends StatelessWidget {
  final String title;

  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Constants.accentColor,
        ),
      ),
    );
  }
}
