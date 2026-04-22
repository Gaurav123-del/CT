import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'contacts_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _voice1Recorded = false;
  bool _voice2Recorded = false;
  bool _voice1Recording = false;
  bool _voice2Recording = false;

  void _recordVoice(int index) async {
    if (index == 1) {
      setState(() => _voice1Recording = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _voice1Recording = false;
        _voice1Recorded = true;
      });
    } else {
      setState(() => _voice2Recording = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _voice2Recording = false;
        _voice2Recorded = true;
      });
    }
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _voice1Recorded &&
      _voice2Recorded;

  void _onContinue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ContactsScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressBar(currentStep: 1),
              const SizedBox(height: 32),

              const SectionHeader(
                title: 'Setup Your\nProfile',
                subtitle: 'We need a few details to keep you safe.',
              ),
              const SizedBox(height: 32),

              // Name field
              const Text(
                'YOUR NAME',
                style: AppTheme.labelText,
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Enter your full name',
                controller: _nameController,
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
              ),

              const SizedBox(height: 32),

              // Voice samples section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: AppTheme.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voice Samples',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Record 2 voice samples ',
                              style: TextStyle(
                                color: AppTheme.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    VoiceRecordButton(
                      label: 'Voice Sample 1',
                      isRecorded: _voice1Recorded,
                      isRecording: _voice1Recording,
                      onPressed: () => _recordVoice(1),
                    ),
                    const SizedBox(height: 12),
                    VoiceRecordButton(
                      label: 'Voice Sample 2',
                      isRecorded: _voice2Recorded,
                      isRecording: _voice2Recording,
                      onPressed: () => _recordVoice(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.accentBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppTheme.accentBlue, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Voice samples help the AI detect when you\'re in distress.',
                        style: TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Both recorded check
              if (_voice1Recorded && _voice2Recorded) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.greenDim.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppTheme.green, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Voice samples recorded successfully',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) {
                  return PrimaryButton(
                    label: 'Continue',
                    onPressed: _canContinue ? _onContinue : () {},
                    color: _canContinue
                        ? AppTheme.green
                        : AppTheme.surfaceLight,
                    textColor: _canContinue
                        ? AppTheme.background
                        : AppTheme.textHint,
                    icon: Icons.arrow_forward_rounded,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({required int currentStep}) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= currentStep - 1;
        final isCurrent = index == currentStep - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? (isCurrent ? AppTheme.green : AppTheme.greenDim)
                  : AppTheme.borderColor,
            ),
          ),
        );
      }),
    );
  }
}