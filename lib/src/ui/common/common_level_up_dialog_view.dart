import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathgame/src/core/app_constant.dart';

class CommonLevelUpDialogView extends StatelessWidget {
  final GameCategoryType gameCategoryType;
  final double score;
  final int questionCount;

  const CommonLevelUpDialogView({
    required this.gameCategoryType,
    required this.score,
    required this.questionCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium Crown/Trophy animated header
        Container(
          height: 100,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                "🎉",
                style: TextStyle(fontSize: 60),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 0.8, end: 1.2, duration: 600.ms)
                  .rotate(begin: -0.1, end: 0.1, duration: 600.ms),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "LEVEL UP!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: const Color(0xffFF6B6B),
            shadows: [
              Shadow(
                color: const Color(0xffFF6B6B).withOpacity(0.3),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          "Great job! You have answered",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$questionCount ",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xffEE5A24),
              ),
            ),
            Text(
              "questions successfully!",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffFF6B6B), Color(0xffEE5A24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffEE5A24).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              "KEEP GOING 🚀",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }
}
