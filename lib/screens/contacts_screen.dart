import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/emergency_contact.dart';
import '../widgets/common_widgets.dart';
import 'emergency_type.dart'; 

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<EmergencyContact> _contacts = [];
  static const int _maxContacts = 5;

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: const Icon(Icons.person_add_rounded,
                        color: AppTheme.green, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add Contact', style: AppTheme.headingSmall),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                hint: 'Contact name',
                label: 'Name',
                controller: nameCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    color: AppTheme.textHint, size: 18),
              ),
              const SizedBox(height: 14),
              AppTextField(
                hint: '+91 XXXXX XXXXX',
                label: 'Phone Number',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppTheme.textHint, size: 18),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isNotEmpty &&
                            phoneCtrl.text.trim().isNotEmpty) {
                          setState(() {
                            _contacts.add(EmergencyContact(
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            ));
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteContact(int index) {
    setState(() => _contacts.removeAt(index));
  }

  // add this import

void _onDone() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => EmergencyTypeScreen(
        contacts: _contacts,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              _buildProgressBar(),
              const SizedBox(height: 28),

              const SectionHeader(
                title: 'Emergency\nContacts',
                subtitle:
                    'These people will be alerted if you need help.',
              ),
              const SizedBox(height: 24),

              // Counter badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _contacts.length >= _maxContacts
                          ? AppTheme.green.withValues(alpha: 0.1)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _contacts.length >= _maxContacts
                            ? AppTheme.green.withValues(alpha: 0.4)
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Text(
                      '${_contacts.length} / $_maxContacts Contacts Added',
                      style: TextStyle(
                        color: _contacts.length >= _maxContacts
                            ? AppTheme.green
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_contacts.length < _maxContacts)
                    GestureDetector(
                      onTap: _showAddContactDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppTheme.background, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Add Contact',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact list
              Expanded(
                child: _contacts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _contacts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _ContactCard(
                            contact: _contacts[index],
                            index: index,
                            onDelete: () => _deleteContact(index),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                label: _contacts.isEmpty ? 'Skip for now' : 'Done →',
                onPressed: _onDone,
                color: _contacts.isEmpty
                    ? AppTheme.surfaceLight
                    : AppTheme.green,
                textColor: _contacts.isEmpty
                    ? AppTheme.textSecondary
                    : AppTheme.background,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: AppTheme.textHint, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'No contacts yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add up to 5 emergency contacts',
            style: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive ? AppTheme.green : AppTheme.borderColor,
            ),
          ),
        );
      }),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final int index;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.green,
      AppTheme.accentBlue,
      const Color(0xFFFFAB40),
      const Color(0xFFE040FB),
      const Color(0xFFFF5252),
    ];
    final color = colors[index % colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                contact.name[0].toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        color: AppTheme.textHint, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      contact.phone,
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}