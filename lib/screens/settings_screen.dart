import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationSound = true;
  bool _glowEffects = true;
  bool _biometricLock = false;
  double _fontSizeOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text(
          'PENGATURAN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2.0,
            color: Color(0xFF00FF88),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00FF88),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF00FF88),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genesis Note Keeper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Premium User',
                          style: TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Preference Section
            _buildSectionHeader('Preferensi UI & Glow'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.lens_blur_rounded,
                title: 'Efek Cahaya Neon (Glow)',
                subtitle: 'Aktifkan bayangan berpendar hijau neon',
                value: _glowEffects,
                onChanged: (val) {
                  setState(() => _glowEffects = val);
                },
              ),
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.format_size_rounded, color: Color(0xFF9CA3AF), size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Ukuran Teks',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          _fontSizeOffset == 0.0
                              ? 'Normal'
                              : _fontSizeOffset > 0
                                  ? '+${_fontSizeOffset.toInt()}'
                                  : '${_fontSizeOffset.toInt()}',
                          style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _fontSizeOffset,
                      min: -2.0,
                      max: 4.0,
                      divisions: 6,
                      activeColor: const Color(0xFF00FF88),
                      inactiveColor: Colors.white.withOpacity(0.08),
                      onChanged: (val) {
                        setState(() => _fontSizeOffset = val);
                      },
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('Keamanan & Notifikasi'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'Suara Notifikasi',
                subtitle: 'Mainkan efek suara untuk pengingat',
                value: _notificationSound,
                onChanged: (val) {
                  setState(() => _notificationSound = val);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                title: 'Kunci Biometrik',
                subtitle: 'Amankan catatan menggunakan sidik jari',
                value: _biometricLock,
                onChanged: (val) {
                  setState(() => _biometricLock = val);
                },
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('Informasi Aplikasi'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildInfoTile(Icons.info_outline_rounded, 'Versi Aplikasi', '1.0.0 (Build 2026.05)'),
              _buildDivider(),
              _buildInfoTile(Icons.code_rounded, 'Arsitektur UI', 'Flutter AMOLED Minimalist'),
            ]),
            const SizedBox(height: 48),

            // Footer Logo
            Center(
              child: Column(
                children: [
                  Text(
                    'GENESIS NOTES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.15),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Futuristic Productivity Suite',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.08),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00FF88),
      activeTrackColor: const Color(0xFF00FF88).withOpacity(0.3),
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade800,
      secondary: Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.03),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
