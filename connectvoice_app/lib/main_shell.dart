import 'package:flutter/material.dart';
import 'theme.dart';
import 'prefs.dart';
import 'room_list_screen.dart';
import 'learn_signs_screen.dart';
import 'profile_screen.dart';
import 'server_gate.dart';

class MainShell extends StatefulWidget {
  final String serverUrl;
  final Prefs prefs;
  const MainShell({super.key, required this.serverUrl, required this.prefs});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const LearnSignsScreen(),
      RoomListScreen(
        prefs: widget.prefs,
        serverUrl: widget.serverUrl,
        onChangeServer: () {
          widget.prefs.clearServerUrl();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ServerGate()),
            (route) => false,
          );
        },
      ),
      ProfileScreen(prefs: widget.prefs),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg1,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Aprender Señas',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.tx3;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}