// Commit 21: 사용자 신체 정보 입력 화면 (키/체중/연령)

import 'package:flutter/material.dart';

import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profileService});

  final ProfileService profileService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _requiredIntInRange(
    String? value, {
    required String fieldName,
    required int min,
    required int max,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName 필수 입력입니다.';
    final parsed = int.tryParse(v);
    if (parsed == null) return '$fieldName 숫자만 입력해 주세요.';
    if (parsed < min || parsed > max) return '$fieldName 범위는 $min~$max 입니다.';
    return null;
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profile = UserProfile(
      heightCm: int.parse(_heightController.text.trim()),
      weightKg: int.parse(_weightController.text.trim()),
      ageYears: int.parse(_ageController.text.trim()),
    );
    widget.profileService.save(profile);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신체 정보 입력'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('height_cm'),
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '키 (cm)',
                ),
                validator: (v) => _requiredIntInRange(
                  v,
                  fieldName: '키',
                  min: 80,
                  max: 250,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('weight_kg'),
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '체중 (kg)',
                ),
                validator: (v) => _requiredIntInRange(
                  v,
                  fieldName: '체중',
                  min: 20,
                  max: 300,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('age_years'),
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '나이',
                ),
                validator: (v) => _requiredIntInRange(
                  v,
                  fieldName: '나이',
                  min: 5,
                  max: 120,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onSave,
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

