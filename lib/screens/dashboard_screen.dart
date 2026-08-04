import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../models/eco_log_model.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int latestScore = 0;
  List<EcoLogModel> logsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final fetchedLogs = await StorageService.getLogs();
    int currentScore = 0;

    if (fetchedLogs.isNotEmpty) {
      final now = DateTime.now();
      final mondayOfThisWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));

      final lastLog = fetchedLogs.last;

      try {
        List<String> parts = lastLog.date.split('-');
        if (parts.length == 3) {
          DateTime lastLogDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          if (!lastLogDate.isBefore(mondayOfThisWeek)) {
            currentScore = lastLog.score;
          }
        }
      } catch (e) {
        debugPrint("Error parsing last log date: $e");
      }
    }

    if (mounted) {
      setState(() {
        logsList = fetchedLogs;
        latestScore = currentScore;
        isLoading = false;
      });
    }
  }

  String _getTipMessage(int score) {
    if (score >= 80) {
      return 'Outstanding effort! You are making a huge green impact.';
    } else if (score >= 50) {
      return 'Great job! Keep up your green habits to raise your score.';
    } else if (score > 0) {
      return 'Good start! Small eco-friendly daily steps make a big difference.';
    } else {
      return 'Log your daily green activities to start building your eco-score!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Your Dashboard',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
            onPressed: loadDashboardData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: latestScore / 100,
                                strokeWidth: 12,
                                backgroundColor: AppColors.primaryLight,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$latestScore',
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'out of 100',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ECO SCORE',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY IMPACT',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) =>
                                      AppColors.textPrimary,
                                  tooltipBorderRadius: BorderRadius.circular(8),
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${rod.toY.round()} pts',
                                      GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const days = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun'
                                      ];
                                      if (value.toInt() < days.length) {
                                        return Text(
                                          days[value.toInt()],
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: generateBarGroups(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getTipMessage(latestScore),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<BarChartGroupData> generateBarGroups() {
    List<double> weeklyScores = List.filled(7, 0.0);

    final now = DateTime.now();
    final mondayOfThisWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sundayOfThisWeek =
        mondayOfThisWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    for (var log in logsList) {
      try {
        List<String> parts = log.date.split('-');
        if (parts.length == 3) {
          DateTime logDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          if (logDate.isAfter(
                  mondayOfThisWeek.subtract(const Duration(seconds: 1))) &&
              logDate.isBefore(sundayOfThisWeek)) {
            int dayIndex = logDate.weekday - 1;
            if (dayIndex >= 0 && dayIndex < 7) {
              weeklyScores[dayIndex] = log.score.toDouble();
            }
          }
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyScores[index],
            color: weeklyScores[index] > 0
                ? AppColors.primaryDark
                : AppColors.border,
            width: 16,
            borderRadius: BorderRadius.circular(6),
          )
        ],
      );
    });
  }
}