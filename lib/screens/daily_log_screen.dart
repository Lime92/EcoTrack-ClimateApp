import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/eco_log_model.dart';
import '../services/storage_service.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  String _selectedTransport = 'walk';
  bool _lightsOff = true;
  bool _reducedAc = false;
  String _selectedWaste = 'recycled';

  void _saveAndCalculate() async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final score = EcoLogModel.calculateScore(
      transport: _selectedTransport,
      lightsOff: _lightsOff,
      reducedAc: _reducedAc,
      waste: _selectedWaste,
    );

    final log = EcoLogModel(
      date: todayStr,
      transport: _selectedTransport,
      lightsOff: _lightsOff,
      reducedAc: _reducedAc,
      waste: _selectedWaste,
      score: score,
    );

    await StorageService.saveLog(log);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryDark,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Eco Score Calculated!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your score for today is',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$score / 100',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily Activity Log',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('TRANSPORTATION'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildOptionCard('Walk', 'walk', Icons.directions_walk),
                const SizedBox(width: 10),
                _buildOptionCard('Bus', 'bus', Icons.directions_bus),
                const SizedBox(width: 10),
                _buildOptionCard('Car', 'car', Icons.directions_car),
              ],
            ),
            const SizedBox(height: 25),
            _buildSectionTitle('ENERGY USE'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    title: const Text('Lights off when leaving room'),
                    value: _lightsOff,
                    onChanged: (val) => setState(() => _lightsOff = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    title: const Text('Reduced AC / Heating usage'),
                    value: _reducedAc,
                    onChanged: (val) => setState(() => _reducedAc = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildSectionTitle('WASTE MANAGEMENT'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: const Text('Recycled properly'),
                    value: 'recycled',
                    groupValue: _selectedWaste,
                    onChanged: (val) => setState(() => _selectedWaste = val!),
                  ),
                  RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: const Text('Composted food waste'),
                    value: 'composted',
                    groupValue: _selectedWaste,
                    onChanged: (val) => setState(() => _selectedWaste = val!),
                  ),
                  RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: const Text('Avoided single-use plastic'),
                    value: 'single_use',
                    groupValue: _selectedWaste,
                    onChanged: (val) => setState(() => _selectedWaste = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _saveAndCalculate,
                child: Text(
                  'Calculate Eco Score',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildOptionCard(String label, String value, IconData icon) {
    final isSelected = _selectedTransport == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTransport = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.cardBackground,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}