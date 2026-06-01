import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mathgame/src/core/app_assets.dart';
import 'package:mathgame/src/core/app_constant.dart';
import 'package:mathgame/src/core/color_scheme.dart';
import 'package:mathgame/src/ui/app/theme_provider.dart';
import 'package:mathgame/src/ui/common/common_alert_dialog.dart';
import 'package:mathgame/src/ui/common/common_difficulty_view.dart';
import 'package:mathgame/src/ui/dashboard/dashboard_button_view.dart';
import 'package:mathgame/src/ui/dashboard/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:mathgame/src/core/ad_manager.dart';
import 'package:tuple/tuple.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetLeftEnter;
  late Animation<Offset> _offsetRightEnter;
  late bool isHomePageOpen;

  @override
  void initState() {
    super.initState();
    isHomePageOpen = false;
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _offsetLeftEnter = Tween<Offset>(
      begin: Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(_controller);

    _offsetRightEnter = Tween<Offset>(
      begin: Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 12),
                        if (!kIsWeb) ...[
                          InkWell(
                            onTap: () {
                              exit(0);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.infoDialogBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: const Icon(
                                Icons.power_settings_new_rounded,
                                color: Color(0xffFF6B6B),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, KeyUtil.leaderboard);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.infoDialogBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppAssets.icTrophy,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 5),
                                Consumer<DashboardProvider>(
                                  builder: (context, model, child) => Text(
                                      model.overallScore.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, KeyUtil.enterName);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.infoDialogBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Color(0xffFF6B6B),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            AdManager.instance.showWatchAdRewardedAd(
                              onRewardEarned: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thank you for watching! Reward earned.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              onClosed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ad not finished. No reward earned.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.infoDialogBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: const Icon(
                              Icons.ondemand_video_rounded,
                              color: Color(0xffFFD700),
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        showDialog<bool>(
                          context: context,
                          builder: (newContext) {
                            final model = Provider.of<ThemeProvider>(context,
                                listen: true);
                            return CommonAlertDialog(
                              child: ChangeNotifierProvider.value(
                                value: model,
                                child: CommonDifficultyView(
                                  selectedDifficulty: model.difficultyType,
                                ),
                              ),
                            );
                          },
                          barrierDismissible: false,
                        ).then((value) {});
                      },
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.infoDialogBgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.only(
                            left: 12, top: 12, bottom: 12, right: 8),
                        child: SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? AppAssets.ic3dStairsDark
                              : AppAssets.ic3dStairsLight,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<ThemeProvider>().changeTheme();
                      },
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.infoDialogBgColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.only(
                            right: 12, top: 12, bottom: 12, left: 8),
                        child: SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? AppAssets.icDarkMode
                              : AppAssets.icLightMode,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
                SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 24),
                        Consumer<DashboardProvider>(
                          builder: (context, model, child) {
                            if (model.username.isEmpty) return const SizedBox.shrink();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: model.gender == "Male"
                                          ? [const Color(0xff4facfe), const Color(0xff00f2fe)]
                                          : [const Color(0xffff9a9e), const Color(0xfffecfef)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (model.gender == "Male"
                                                ? const Color(0xff00f2fe)
                                                : const Color(0xfffecfef))
                                            .withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    model.avatar,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: "Player: ",
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                    children: [
                                      TextSpan(
                                        text: "(${model.username})",
                                        style: const TextStyle(
                                          fontFamily: 'cursive',
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xffFF6B6B),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Math GenZ",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Train Your Brain, Improve Your Math Skill",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 14),
                        ),
                        SizedBox(height: 36),
                        DashboardButtonView(
                          dashboard: KeyUtil.dashboardItems[0],
                          position: _offsetLeftEnter,
                          onTab: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              KeyUtil.home,
                              ModalRoute.withName(KeyUtil.dashboard),
                              arguments: Tuple2(KeyUtil.dashboardItems[0],
                                  MediaQuery.of(context).padding.top),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        DashboardButtonView(
                          dashboard: KeyUtil.dashboardItems[1],
                          position: _offsetRightEnter,
                          onTab: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              KeyUtil.home,
                              ModalRoute.withName(KeyUtil.dashboard),
                              arguments: Tuple2(KeyUtil.dashboardItems[1],
                                  MediaQuery.of(context).padding.top),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        DashboardButtonView(
                          dashboard: KeyUtil.dashboardItems[2],
                          position: _offsetLeftEnter,
                          onTab: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              KeyUtil.home,
                              ModalRoute.withName(KeyUtil.dashboard),
                              arguments: Tuple2(KeyUtil.dashboardItems[2],
                                  MediaQuery.of(context).padding.top),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.light
                          ? [const Color(0xfff7f7f7), const Color(0xffffffff)]
                          : [const Color(0xff1f1310), const Color(0xff2d1810)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0x1a000000)
                          : const Color(0x33FF6B6B),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: Text(
                    "© Muhammed Rihan. All rights reserved.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white70,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
