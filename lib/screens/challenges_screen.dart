import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/storage_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _points = 0;
  List<String> _completedIds = [];

  final List<Map<String, dynamic>> _challenges = [
    {
      'id': '1',
      'title': 'Unplug chargers when idle',
      'pts': 15,
      'icon': Icons.power_rounded
    },
    {
      'id': '2',
      'title': 'Take a 5-minute shorter shower',
      'pts': 10,
      'icon': Icons.water_drop_rounded
    },
    {
      'id': '3',
      'title': 'Bring a reusable bag when shopping',
      'pts': 10,
      'icon': Icons.shopping_bag_rounded
    },
    {
      'id': '4',
      'title': 'Bike or walk instead of driving',
      'pts': 20,
      'icon': Icons.directions_bike_rounded
    },
    {
      'id': '5',
      'title': 'Sort recyclables before bin day',
      'pts': 15,
      'icon': Icons.recycling_rounded
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pts = await StorageService.getPoints();
    final completed = await StorageService.getCompletedChallenges();
    setState(() {
      _points = pts;
      _completedIds = completed;
    });
  }

  void _toggleChallenge(String id, int pts) async {
    await StorageService.toggleChallenge(id, pts);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily Challenges',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_points pts',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _challenges.length,
        itemBuilder: (context, index) {
          final item = _challenges[index];
          final isDone = _completedIds.contains(item['id']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDone ? AppColors.primaryLight : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone ? AppColors.primary : AppColors.border,
              ),
            ),
            child: ListTile(
              leading: Icon(item['icon'],
                  color: isDone ? AppColors.primaryDark : AppColors.textSecondary),
              title: Text(
                item['title'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '+${item['pts']} pts',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              trailing: Checkbox(
                activeColor: AppColors.primary,
                value: isDone,
                onChanged: (val) => _toggleChallenge(item['id'], item['pts']),
              ),
            ),
          );
        },
      ),
    );
  }
}