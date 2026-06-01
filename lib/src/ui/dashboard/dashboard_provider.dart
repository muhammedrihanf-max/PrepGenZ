import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mathgame/src/core/app_assets.dart';
import 'package:mathgame/src/data/models/score_board.dart';
import 'package:mathgame/src/core/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mathgame/src/core/supabase_config.dart';

import '../../data/models/game_category.dart';

class DashboardProvider extends ChangeNotifier {
  int _overallScore = 0;
  late List<GameCategory> _list;
  final SharedPreferences preferences;

  int get overallScore => _overallScore;

  List<GameCategory> get list => _list;

  DashboardProvider({required this.preferences}) {
    _overallScore = getOverallScore();
  }

  List<GameCategory> getGameByPuzzleType(PuzzleType puzzleType) {
    _list = <GameCategory>[];
    switch (puzzleType) {
      case PuzzleType.MATH_PUZZLE:
        list.add(GameCategory(
          1,
          "Calculator",
          "calculator",
          GameCategoryType.CALCULATOR,
          KeyUtil.calculator,
          getScoreboard("calculator"),
          AppAssets.icCalculator,
        ));
        list.add(GameCategory(
            2,
            "Guess the sign?",
            "sign",
            GameCategoryType.GUESS_SIGN,
            KeyUtil.guessSign,
            getScoreboard("sign"),
            AppAssets.icGuessTheSign));
        list.add(GameCategory(
          5,
          "Correct answer",
          "correct_answer",
          GameCategoryType.CORRECT_ANSWER,
          KeyUtil.correctAnswer,
          getScoreboard("correct_answer"),
          AppAssets.icCorrectAnswer,
        ));
        list.add(GameCategory(
          8,
          "Quick calculation",
          "quick_calclation",
          GameCategoryType.QUICK_CALCULATION,
          KeyUtil.quickCalculation,
          getScoreboard("quick_calclation"),
          AppAssets.icQuickCalculation,
        ));
        break;
      case PuzzleType.MEMORY_PUZZLE:
        list.add(GameCategory(
          7,
          "Mental arithmetic",
          "mental_arithmatic",
          GameCategoryType.MENTAL_ARITHMETIC,
          KeyUtil.mentalArithmetic,
          getScoreboard("mental_arithmatic"),
          AppAssets.icMentalArithmetic,
        ));
        list.add(GameCategory(
          3,
          "Square root",
          "square_root",
          GameCategoryType.SQUARE_ROOT,
          KeyUtil.squareRoot,
          getScoreboard("square_root"),
          AppAssets.icSquareRoot,
        ));
        list.add(GameCategory(
          9,
          "Math Grid",
          "math_machine",
          GameCategoryType.MATH_GRID,
          KeyUtil.mathGrid,
          getScoreboard("math_machine"),
          AppAssets.icMathGrid,
        ));
        list.add(GameCategory(
          4,
          "Mathematical pairs",
          "math_pairs",
          GameCategoryType.MATH_PAIRS,
          KeyUtil.mathPairs,
          getScoreboard("math_pairs"),
          AppAssets.icMathematicalPairs,
        ));
        break;
      case PuzzleType.BRAIN_PUZZLE:
        list.add(GameCategory(
          6,
          "Magic triangle",
          "magic_tringle",
          GameCategoryType.MAGIC_TRIANGLE,
          KeyUtil.magicTriangle,
          getScoreboard("magic_tringle"),
          AppAssets.icMagicTriangle,
        ));
        list.add(GameCategory(
          10,
          "Picture Puzzle",
          "picture_puzzle",
          GameCategoryType.PICTURE_PUZZLE,
          KeyUtil.picturePuzzle,
          getScoreboard("picture_puzzle"),
          AppAssets.icPicturePuzzle,
        ));
        list.add(GameCategory(
          11,
          "Number Pyramid",
          "number_pyramid",
          GameCategoryType.NUMBER_PYRAMID,
          KeyUtil.numberPyramid,
          getScoreboard("number_pyramid"),
          AppAssets.icNumberPyramid,
        ));
        break;
    }
    return _list;
  }

  ScoreBoard getScoreboard(String gameCategoryType) {
    return ScoreBoard.fromJson(
        json.decode(preferences.getString(gameCategoryType) ?? "{}"));
  }

  void setScoreboard(String gameCategoryType, ScoreBoard scoreboard) {
    preferences.setString(gameCategoryType, json.encode(scoreboard.toJson()));
  }

  void updateScoreboard(GameCategoryType gameCategoryType, double newScore) {
    list.forEach((gameCategory) {
      if (gameCategory.gameCategoryType == gameCategoryType) {
        if (gameCategory.scoreboard.highestScore < newScore.toInt()) {
          setOverallScore(
              gameCategory.scoreboard.highestScore, newScore.toInt());
          gameCategory.scoreboard.highestScore = newScore.toInt();
        }
        setScoreboard(gameCategory.key, gameCategory.scoreboard);
      }
    });
    notifyListeners();
  }

  String get username => preferences.getString("username") ?? "";

  set username(String name) {
    preferences.setString("username", name);
    updateLeaderboard();
    notifyListeners();
  }

  String get gender => preferences.getString("gender") ?? "Male";

  set gender(String value) {
    preferences.setString("gender", value);
    notifyListeners();
  }

  String get avatar => preferences.getString("avatar") ?? "👦";

  set avatar(String value) {
    preferences.setString("avatar", value);
    notifyListeners();
  }

  List<Map<String, dynamic>>? _leaderboardCache;

  List<Map<String, dynamic>> getLeaderboard() {
    if (_leaderboardCache != null) {
      return _leaderboardCache!;
    }
    final String? jsonStr = preferences.getString("leaderboard");
    if (jsonStr == null) {
      // Return some default dummy players to make the leaderboard look beautiful on start
      _leaderboardCache = [
        {"username": "Brainiac", "score": 150, "gender": "Male", "avatar": "👦"},
        {"username": "MathWizard", "score": 120, "gender": "Male", "avatar": "👦"},
        {"username": "Einstein", "score": 90, "gender": "Male", "avatar": "👦"},
        {"username": "Newton", "score": 60, "gender": "Male", "avatar": "👦"},
      ];
      return _leaderboardCache!;
    }
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      final List<Map<String, dynamic>> list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      list.sort((a, b) => (b["score"] as num).compareTo(a["score"] as num));
      _leaderboardCache = list;
      return _leaderboardCache!;
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchLeaderboardFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final response = await Supabase.instance.client
          .from('leaderboard')
          .select('username, score, gender, avatar')
          .order('score', ascending: false)
          .limit(25);
      
      final List<Map<String, dynamic>> fetchedList = List<Map<String, dynamic>>.from(response as List);
      if (fetchedList.isNotEmpty) {
        _leaderboardCache = fetchedList;
        preferences.setString("leaderboard", json.encode(fetchedList));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching from Supabase: $e");
    }
  }

  void updateLeaderboard() {
    final name = username.trim();
    if (name.isEmpty) return;
    final currentScore = overallScore;
    final userGender = gender;
    final userAvatar = avatar;
    
    // Get existing list
    final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(getLeaderboard());
    
    final index = list.indexWhere((element) => element["username"].toString().toLowerCase() == name.toLowerCase());
    if (index != -1) {
      if ((list[index]["score"] as num) < currentScore) {
        list[index]["score"] = currentScore;
        list[index]["gender"] = userGender;
        list[index]["avatar"] = userAvatar;
      }
    } else {
      list.add({
        "username": name,
        "score": currentScore,
        "gender": userGender,
        "avatar": userAvatar,
      });
    }
    
    list.sort((a, b) => (b["score"] as num).compareTo(a["score"] as num));
    _leaderboardCache = list;
    preferences.setString("leaderboard", json.encode(list));
    notifyListeners();

    // Async push to Supabase
    if (SupabaseConfig.isConfigured) {
      Supabase.instance.client.from('leaderboard').upsert({
        'username': name,
        'score': currentScore,
        'gender': userGender,
        'avatar': userAvatar,
      }, onConflict: 'username').then((_) {
        fetchLeaderboardFromSupabase();
      }).catchError((e) {
        debugPrint("Error pushing to Supabase: $e");
      });
    }
  }

  int getOverallScore() {
    return preferences.getInt("overall_score") ?? 0;
  }

  void setOverallScore(int highestScore, int newScore) {
    _overallScore = getOverallScore() - highestScore + newScore;
    preferences.setInt("overall_score", _overallScore);
    updateLeaderboard();
  }

  bool isFirstTime(GameCategoryType gameCategoryType) {
    return list
        .where((GameCategory gameCategory) =>
            gameCategory.gameCategoryType == gameCategoryType)
        .first
        .scoreboard
        .firstTime;
  }

  void setFirstTime(GameCategoryType gameCategoryType) {
    list.forEach((gameCategory) {
      if (gameCategory.gameCategoryType == gameCategoryType) {
        gameCategory.scoreboard.firstTime = false;
        setScoreboard(gameCategory.key, gameCategory.scoreboard);
      }
    });
  }
}
