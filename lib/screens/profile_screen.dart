import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_session.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // Example state for profile data
  String _phone = '+91 98765 43210';
  String _email = 'rajesh.kumar@shgbank.in';
  String _zone = 'Rampur Block, UP';

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _zoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _phone;
    _emailController.text = _email;
    _zoneController.text = _zone;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Save changes
        _phone = _phoneController.text;
        _email = _emailController.text;
        _zone = _zoneController.text;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _isEditing = !_isEditing;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your session?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await AuthSession.instance.clear();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // remove all previous routes
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMenuClick(String label) {
    if (label == 'Collection History') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your collection history is currently up to date.')),
      );
    } else if (label == 'Notifications') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have 0 new notifications.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening $label...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: _toggleEdit,
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildInfoSection(),
          const SizedBox(height: 16),
          _buildMenuSection(context),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'RK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Rajesh Kumar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Field Collection Officer',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Employee ID: EMP-2024-0087',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('24', 'Groups'),
          _vDivider(),
          _stat('147', 'Members'),
          _vDivider(),
          _stat('₹4.7L', 'Collected'),
          _vDivider(),
          _stat('96%', 'Target'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: Colors.white30);

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personal Information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              if (_isEditing)
                const Text('Editing Mode',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildEditableRow(Icons.phone_rounded, 'Phone', _phoneController),
          _buildEditableRow(Icons.email_rounded, 'Email', _emailController),
          _buildEditableRow(Icons.location_on_rounded, 'Zone', _zoneController),
          _infoRow(Icons.calendar_today_rounded, 'Joined', 'March 2022', false),
        ],
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String label, TextEditingController controller) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return _infoRow(icon, label, controller.text, true);
    }
  }

  Widget _infoRow(IconData icon, String label, String value, bool addPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: addPadding ? 8 : 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {'icon': Icons.history_rounded, 'label': 'Collection History', 'color': AppTheme.primaryColor},
      {'icon': Icons.description_rounded, 'label': 'My Reports', 'color': AppTheme.accentColor},
      {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.help_outline_rounded, 'label': 'Help & Support', 'color': AppTheme.secondaryColor},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': Colors.grey},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: item['color'] as Color, size: 18),
                ),
                title: Text(item['label'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey),
                onTap: () => _handleMenuClick(item['label'] as String),
              ),
              if (index < menuItems.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text('Logout',
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
