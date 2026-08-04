import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'daily_log_screen.dart';
import 'dashboard_screen.dart';
import 'challenges_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return const DailyLogScreen();
      case 1:
        return const DashboardScreen();
      case 2:
        return const ChallengesScreen();
      default:
        return const DailyLogScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(_currentIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.cardBackground,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar_rounded),
              label: 'Daily Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'Challenges',
            ),
          ],
        ),
      ),
    );
  }
}