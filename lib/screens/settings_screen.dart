import 'package:flutter/material.dart';
import '../utils/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        final settings = SettingsManager.instance;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'PENGATURAN',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2.0,
                color: theme.colorScheme.primary,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Just trigger a rebuild
              setState(() {});
            },
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('PREFERENSI APLIKASI'),
                  const SizedBox(height: 12),
                  
                  // Main Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.04) 
                            : Colors.black.withOpacity(0.04),
                        width: 1,
                      ),
                      boxShadow: settings.glowEffects && isDark
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.05),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        // 1. Dark / Light Mode Switch
                        _buildSwitchTile(
                          icon: settings.isDarkMode 
                              ? Icons.dark_mode_rounded 
                              : Icons.light_mode_rounded,
                          title: 'Mode Gelap & Terang',
                          subtitle: settings.isDarkMode ? 'Tema Gelap AMOLED Aktif' : 'Tema Terang Aktif',
                          value: settings.isDarkMode,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            settings.updateDarkMode(val);
                          },
                        ),
                        
                        _buildDivider(isDark),

                        // 2. Glow Effects Switch
                        _buildSwitchTile(
                          icon: Icons.lens_blur_rounded,
                          title: 'Efek Cahaya (Glow)',
                          subtitle: 'Aktifkan bayangan berpendar hijau neon',
                          value: settings.glowEffects,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            settings.updateGlowEffects(val);
                          },
                        ),

                        _buildDivider(isDark),

                        // 3. Font Size Offset Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.format_size_rounded, 
                                        color: isDark ? const Color(0xFF9CA3AF) : Colors.black54, 
                                        size: 22
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Ukuran Teks',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    settings.fontSizeOffset == 0.0
                                        ? 'Normal'
                                        : settings.fontSizeOffset > 0
                                            ? '+${settings.fontSizeOffset.toInt()}'
                                            : '${settings.fontSizeOffset.toInt()}',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: settings.fontSizeOffset,
                                min: -2.0,
                                max: 4.0,
                                divisions: 6,
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: isDark 
                                    ? Colors.white.withOpacity(0.08) 
                                    : Colors.black.withOpacity(0.08),
                                onChanged: (val) {
                                  settings.updateFontSizeOffset(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Footer Logo
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'MEMOHARI CATATAN',
                          style: TextStyle(
                            color: isDark 
                                ? Colors.white.withOpacity(0.15) 
                                : Colors.black.withOpacity(0.15),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aplikasi Catatan Produktivitas Anda',
                          style: TextStyle(
                            color: isDark 
                                ? Colors.white.withOpacity(0.08) 
                                : Colors.black.withOpacity(0.08),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor.withOpacity(0.3),
      inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      secondary: Icon(
        icon, 
        color: isDark ? const Color(0xFF9CA3AF) : Colors.black54, 
        size: 22
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
