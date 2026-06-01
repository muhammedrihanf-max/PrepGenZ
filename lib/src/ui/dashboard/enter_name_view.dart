import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathgame/src/core/app_constant.dart';
import 'package:mathgame/src/ui/dashboard/dashboard_provider.dart';
import 'package:provider/provider.dart';

import 'package:mathgame/src/core/audio_manager.dart';

class EnterNameView extends StatefulWidget {
  const EnterNameView({Key? key}) : super(key: key);

  @override
  State<EnterNameView> createState() => _EnterNameViewState();
}

class _EnterNameViewState extends State<EnterNameView> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedGender = "Male";
  String _selectedAvatar = "👦";

  final List<String> _maleAvatars = ["👦", "👨", "🦸‍♂️"];
  final List<String> _femaleAvatars = ["👧", "👩", "🦸‍♀️"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      _nameController.text = provider.username;
      setState(() {
        _selectedGender = provider.gender;
        _selectedAvatar = provider.avatar;
      });
      // Try playing BGM on enter name view initial load as well
      AudioManager.instance.playGameplayBgm();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _enterGame() {
    AudioManager.instance.playClick();
    AudioManager.instance.playGameplayBgm();
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.username = name;
      provider.gender = _selectedGender;
      provider.avatar = _selectedAvatar;
      Navigator.pushReplacementNamed(context, KeyUtil.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: theme.brightness,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.light
                  ? [const Color(0xfff3f4f6), const Color(0xffe5e7eb)]
                  : [const Color(0xff2d1810), const Color(0xff1a0d08)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered/Constrained layout container for professional look on web/wide screens
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Premium header controller row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!kIsWeb)
                              IconButton(
                                tooltip: "Close Application",
                                icon: const Icon(
                                  Icons.power_settings_new_rounded,
                                  color: Color(0xffFF6B6B),
                                ),
                                onPressed: () {
                                  exit(0);
                                },
                              )
                            else
                              const SizedBox.shrink(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: "Toggle Sound Effects",
                                  icon: Icon(
                                    AudioManager.instance.isSoundEffectsEnabled
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: const Color(0xffFF6B6B),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      AudioManager.instance.toggleSoundEffects();
                                    });
                                    AudioManager.instance.playClick();
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: "Toggle Game Music",
                                  icon: Icon(
                                    AudioManager.instance.isBgmEnabled
                                        ? Icons.music_note_rounded
                                        : Icons.music_off_rounded,
                                    color: const Color(0xffEE5A24),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      AudioManager.instance.toggleBgm();
                                    });
                                    AudioManager.instance.playClick();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Title / Logo Area
                        Text(
                          "MATH GENZ",
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: const Color(0xffFF6B6B),
                            shadows: [
                              Shadow(
                                color: const Color(0xffFF6B6B).withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                        const SizedBox(height: 8),
                        Text(
                          "Train Your Brain & Rise to the Top",
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                        const SizedBox(height: 40),

                        // Name Input Card
                        Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: theme.brightness == Brightness.light
                                    ? [const Color(0xfffcfcfc), Colors.white]
                                    : [const Color(0xff1f1310), const Color(0xff2d1810)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: theme.brightness == Brightness.light
                                    ? const Color(0x1a000000)
                                    : const Color(0x26FF6B6B),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.05 : 0.2),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Enter Player Name",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 19,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  // Fancy stylized text for entered username
                                  style: const TextStyle(
                                    fontFamily: 'Courier', // Gives it a premium terminal/game look
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: Color(0xffFF6B6B),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ENTER USERNAME...",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 18,
                                      letterSpacing: 2.0,
                                      fontWeight: FontWeight.bold,
                                      color: theme.hintColor.withOpacity(0.3),
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Icon(
                                        Icons.sports_esports_rounded,
                                        color: Color(0xffFF6B6B),
                                        size: 26,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: theme.brightness == Brightness.light
                                        ? const Color(0xfff3f4f6)
                                        : Colors.black.withOpacity(0.3),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: theme.brightness == Brightness.light
                                            ? Colors.black.withOpacity(0.05)
                                            : const Color(0x1aFF6B6B),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Color(0xffFF6B6B),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter your name";
                                    }
                                    if (value.trim().length > 15) {
                                      return "Name cannot exceed 15 characters";
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _enterGame(),
                                  onChanged: (text) {
                                    // Live update name state to keep button message dynamic
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Gender Selector
                                Text(
                                  "Select Gender",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          AudioManager.instance.playClick();
                                          setState(() {
                                            _selectedGender = "Male";
                                            _selectedAvatar = _maleAvatars[0];
                                          });
                                        },
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: _selectedGender == "Male"
                                                ? const LinearGradient(colors: [Color(0xffFF6B6B), Color(0xffEE5A24)])
                                                : null,
                                            color: _selectedGender == "Male"
                                                ? null
                                                : theme.brightness == Brightness.light
                                                    ? const Color(0xfff3f4f6)
                                                    : Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: _selectedGender == "Male"
                                                  ? Colors.transparent
                                                  : theme.dividerColor.withOpacity(0.15),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text("👦", style: TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(
                                                "MALE",
                                                style: TextStyle(
                                                  color: _selectedGender == "Male" ? Colors.white : theme.textTheme.bodyMedium?.color,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          AudioManager.instance.playClick();
                                          setState(() {
                                            _selectedGender = "Female";
                                            _selectedAvatar = _femaleAvatars[0];
                                          });
                                        },
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: _selectedGender == "Female"
                                                ? const LinearGradient(colors: [Color(0xffFF6B6B), Color(0xffEE5A24)])
                                                : null,
                                            color: _selectedGender == "Female"
                                                ? null
                                                : theme.brightness == Brightness.light
                                                    ? const Color(0xfff3f4f6)
                                                    : Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: _selectedGender == "Female"
                                                  ? Colors.transparent
                                                  : theme.dividerColor.withOpacity(0.15),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text("👧", style: TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(
                                                "FEMALE",
                                                style: TextStyle(
                                                  color: _selectedGender == "Female" ? Colors.white : theme.textTheme.bodyMedium?.color,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Avatar Selector
                                Text(
                                  "Select Avatar",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: (_selectedGender == "Male" ? _maleAvatars : _femaleAvatars).map((emoji) {
                                    final isSelected = _selectedAvatar == emoji;
                                    return GestureDetector(
                                      onTap: () {
                                        AudioManager.instance.playClick();
                                        setState(() {
                                          _selectedAvatar = emoji;
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xffFF6B6B).withOpacity(0.2)
                                              : theme.brightness == Brightness.light
                                                  ? const Color(0xfff3f4f6)
                                                  : Colors.black.withOpacity(0.2),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xffFF6B6B) : Colors.transparent,
                                            width: 3,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xffFF6B6B).withOpacity(0.4),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 28),
                                // Enter Game Button (Attractive Gradient CTA)
                                Container(
                                  width: double.infinity,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xffFF6B6B), Color(0xffEE5A24)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffEE5A24).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: _enterGame,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _nameController.text.trim().isEmpty
                                            ? const Text(
                                                "START GAME",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.2,
                                                ),
                                              )
                                            : RichText(
                                                text: TextSpan(
                                                  text: "PLAY AS ",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.2,
                                                    color: Colors.white,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "(${_nameController.text.trim().toUpperCase()})",
                                                      style: const TextStyle(
                                                        fontFamily: 'cursive',
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.play_arrow_rounded, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
