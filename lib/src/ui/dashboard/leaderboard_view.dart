import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathgame/src/ui/dashboard/dashboard_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  String selectedTab = "Today"; // "Today", "Week", "Month"

  // Pre-configured mock data for "Week" and "Month" tabs to make the app feel alive and premium
  final List<Map<String, dynamic>> weekLeaderboard = [
    {"username": "Oliver", "score": 2850, "rank": 1, "trend": "up"},
    {"username": "Robert", "score": 2420, "rank": 2, "trend": "down"},
    {"username": "Jonathan", "score": 2100, "rank": 3, "trend": "up"},
    {"username": "Sophia", "score": 1950, "rank": 4, "trend": "up"},
    {"username": "Jackson", "score": 1820, "rank": 5, "trend": "flat"},
    {"username": "Emma", "score": 1700, "rank": 6, "trend": "up"},
    {"username": "Aria", "score": 1550, "rank": 7, "trend": "down"},
    {"username": "Lucas", "score": 1400, "rank": 8, "trend": "up"},
    {"username": "Brainiac", "score": 1250, "rank": 9, "trend": "flat"},
    {"username": "MathWizard", "score": 1100, "rank": 10, "trend": "down"},
  ];

  final List<Map<String, dynamic>> monthLeaderboard = [
    {"username": "Jackson", "score": 9850, "rank": 1, "trend": "up"},
    {"username": "Oliver", "score": 8900, "rank": 2, "trend": "up"},
    {"username": "Emma", "score": 8420, "rank": 3, "trend": "flat"},
    {"username": "Robert", "score": 7950, "rank": 4, "trend": "down"},
    {"username": "Aria", "score": 7500, "rank": 5, "trend": "up"},
    {"username": "Jonathan", "score": 6800, "rank": 6, "trend": "up"},
    {"username": "Sophia", "score": 6200, "rank": 7, "trend": "down"},
    {"username": "Lucas", "score": 5900, "rank": 8, "trend": "flat"},
    {"username": "Newton", "score": 5100, "rank": 9, "trend": "up"},
    {"username": "Einstein", "score": 4800, "rank": 10, "trend": "up"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchLeaderboardFromSupabase();
    });
  }

  String _getAvatarForUser(String name, String currentUsername, String currentUserAvatar, {String? entryAvatar}) {
    if (entryAvatar != null && entryAvatar.isNotEmpty) {
      return entryAvatar;
    }
    final cleanName = name.replaceAll(" (You)", "").replaceAll("(You)", "").trim();
    if (cleanName.toLowerCase() == currentUsername.toLowerCase() && cleanName.isNotEmpty) {
      return currentUserAvatar;
    }
    switch (cleanName) {
      case "Oliver":
        return "👦";
      case "Robert":
        return "👨";
      case "Jonathan":
        return "🦸‍♂️";
      case "Sophia":
        return "👧";
      case "Emma":
        return "👩";
      case "Aria":
        return "🦸‍♀️";
      case "Jackson":
        return "👨";
      case "Lucas":
        return "👦";
      case "Brainiac":
        return "🦸‍♂️";
      case "MathWizard":
        return "🧙‍♂️";
      case "Einstein":
        return "👨‍🔬";
      case "Newton":
        return "👨‍🎓";
      case "Galileo":
        return "🔭";
      default:
        return "👤";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    // Dynamic processing of "Today" leaderboard from the provider (local scores)
    final localEntries = provider.getLeaderboard();
    final List<Map<String, dynamic>> todayLeaderboard = [];
    for (int i = 0; i < localEntries.length; i++) {
      final entry = localEntries[i];
      todayLeaderboard.add({
        "username": entry["username"] ?? "Unknown",
        "score": entry["score"] ?? 0,
        "avatar": entry["avatar"],
        "gender": entry["gender"],
        "rank": i + 1,
        "trend": i % 3 == 0 ? "up" : (i % 3 == 1 ? "down" : "flat"),
      });
    }

    // Determine current display list based on active tab
    List<Map<String, dynamic>> activeList = [];
    if (selectedTab == "Today") {
      activeList = todayLeaderboard;
    } else {
      final List<Map<String, dynamic>> rawList =
          selectedTab == "Week" ? weekLeaderboard : monthLeaderboard;
      final List<Map<String, dynamic>> processed =
          rawList.map((e) => Map<String, dynamic>.from(e)).toList();
      final playerIndex = processed.indexWhere((e) =>
          e["username"].toString().toLowerCase() ==
          provider.username.toLowerCase());
      if (playerIndex != -1) {
        if ((processed[playerIndex]["score"] as num) < provider.overallScore) {
          processed[playerIndex]["score"] = provider.overallScore;
        }
      } else if (provider.username.isNotEmpty) {
        processed.add({
          "username": provider.username,
          "score": provider.overallScore,
          "gender": provider.gender,
          "avatar": provider.avatar,
        });
      }
      processed.sort((a, b) => (b["score"] as num).compareTo(a["score"] as num));
      for (int i = 0; i < processed.length; i++) {
        processed[i]["rank"] = i + 1;
        processed[i]["trend"] =
            i % 3 == 0 ? "up" : (i % 3 == 1 ? "down" : "flat");
      }
      activeList = processed;
    }

    // Ensure we have at least 3 players to draw the podium safely
    final podiumList = List<Map<String, dynamic>>.from(activeList);
    while (podiumList.length < 3) {
      final placeholderNames = ["Einstein", "Newton", "Galileo"];
      final placeholderName = placeholderNames[podiumList.length % placeholderNames.length];
      podiumList.add({
        "username": placeholderName,
        "score": 50 - (podiumList.length * 10),
        "rank": podiumList.length + 1,
        "trend": "flat",
      });
    }

    // Sort to extract 1st, 2nd, and 3rd rank details
    final rank1 = podiumList[0];
    final rank2 = podiumList[1];
    final rank3 = podiumList[2];

    // Find the remaining players (ranks 4+)
    final remainingPlayers = activeList.length > 3 ? activeList.sublist(3) : <Map<String, dynamic>>[];

    // Check if the current user is in the leaderboard and get their rank card
    final currentUserRankInfo = _getCurrentUserRankInfo(activeList, provider.username);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xff181024),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff1e122b),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff2B1D3D), // Sleek deep purple from the design
                Color(0xff181024),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Leaderboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                        onPressed: () {
                          // Simple share confirmation toast/snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xffFF8C00),
                              content: Text(
                                "Sharing ${provider.username.isNotEmpty ? "${provider.username}'s" : "Math GenZ"} rank score of ${provider.overallScore} pts!",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Tab Selector (Today, Week, Month)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xff1f132e),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                    ),
                    child: Row(
                      children: ["Today", "Week", "Month"].map((tab) {
                        final isSelected = selectedTab == tab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = tab;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xff392754) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xff392754).withOpacity(0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Top 3 Podium layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    height: 195,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Rank 2 (Left)
                        _buildPodiumUser(
                          name: rank2["username"],
                          avatar: _getAvatarForUser(rank2["username"], provider.username, provider.avatar, entryAvatar: rank2["avatar"]),
                          score: rank2["score"],
                          rank: 2,
                          color: const Color(0xff00d2ff),
                          avatarSize: 68,
                          crown: false,
                        ),

                        // Rank 1 (Center)
                        _buildPodiumUser(
                          name: rank1["username"],
                          avatar: _getAvatarForUser(rank1["username"], provider.username, provider.avatar, entryAvatar: rank1["avatar"]),
                          score: rank1["score"],
                          rank: 1,
                          color: const Color(0xffFFD700),
                          avatarSize: 84,
                          crown: true,
                        ),

                        // Rank 3 (Right)
                        _buildPodiumUser(
                          name: rank3["username"],
                          avatar: _getAvatarForUser(rank3["username"], provider.username, provider.avatar, entryAvatar: rank3["avatar"]),
                          score: rank3["score"],
                          rank: 3,
                          color: const Color(0xffFF8C00),
                          avatarSize: 68,
                          crown: false,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Floating user anchor card if applicable
                if (currentUserRankInfo != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                    child: _buildRankCapsule(
                      rank: currentUserRankInfo["rank"],
                      name: currentUserRankInfo["username"] + " (You)",
                      avatar: provider.avatar,
                      score: currentUserRankInfo["score"],
                      trend: currentUserRankInfo["trend"],
                      highlightType: "current",
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                // Remaining Ranks List
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff181024),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: remainingPlayers.isEmpty
                          ? const Center(
                              child: Text(
                                "No additional ranks yet",
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 40.0),
                              itemCount: remainingPlayers.length,
                              itemBuilder: (context, index) {
                                final player = remainingPlayers[index];
                                final rank = player["rank"] as int;
                                final name = player["username"] as String;
                                final score = player["score"] as int;
                                final trend = player["trend"] as String;
                                final userAvatar = _getAvatarForUser(name, provider.username, provider.avatar, entryAvatar: player["avatar"]);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildRankCapsule(
                                    rank: rank,
                                    name: name,
                                    avatar: userAvatar,
                                    score: score,
                                    trend: trend,
                                    highlightType: name.toLowerCase() == provider.username.toLowerCase()
                                        ? "current"
                                        : "normal",
                                  ),
                                );
                              },
                            ),
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

  // Find user's info in active list to draw the top float bar
  Map<String, dynamic>? _getCurrentUserRankInfo(List<Map<String, dynamic>> activeList, String name) {
    if (name.isEmpty) return null;
    final index = activeList.indexWhere((element) => element["username"].toString().toLowerCase() == name.toLowerCase());
    if (index != -1) {
      return activeList[index];
    }
    return null;
  }

  // Builder for Podium User circle (1st, 2nd, 3rd)
  Widget _buildPodiumUser({
    required String name,
    required String avatar,
    required int score,
    required int rank,
    required Color color,
    required double avatarSize,
    required bool crown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // User Avatar Circle
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: rank == 1 ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(avatarSize / 2),
                child: Container(
                  color: const Color(0xff2b1f3c),
                  alignment: Alignment.center,
                  child: Text(
                    avatar,
                    style: TextStyle(
                      fontSize: rank == 1 ? 36 : 28,
                    ),
                  ),
                ),
              ),
            ),

            // Crown for number 1
            if (crown)
              Positioned(
                top: -34,
                child: const Text(
                  "👑",
                  style: TextStyle(fontSize: 32),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .rotate(begin: -0.05, end: 0.05, duration: 2.seconds)
                 .slideY(begin: 0.05, end: -0.05, duration: 1.5.seconds),
              ),

            // Rank Badge at bottom of circle
            Positioned(
              bottom: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xff1e122b), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    color: rank == 1 || rank == 2 ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "($name)",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'cursive',
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$score pts",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // Builder for Capsule List Row item
  Widget _buildRankCapsule({
    required int rank,
    required String name,
    required String avatar,
    required int score,
    required String trend,
    required String highlightType, // "normal", "current"
  }) {
    Color bg;
    Color textColor;
    Color scoreColor;

    if (highlightType == "current") {
      bg = const Color(0xffEE5A24); // Floating/Highlight Orange capsule
      textColor = Colors.white;
      scoreColor = Colors.white;
    } else if (rank == 1) {
      bg = const Color(0xffFFD700); // Gold capsule for rank 1
      textColor = Colors.black;
      scoreColor = Colors.black87;
    } else if (rank == 2) {
      bg = Colors.white; // White capsule for rank 2
      textColor = Colors.black;
      scoreColor = Colors.black87;
    } else if (rank == 3) {
      bg = const Color(0xffFF8C00); // Copper/Orange capsule for rank 3
      textColor = Colors.white;
      scoreColor = Colors.white;
    } else {
      bg = const Color(0xff221731); // Sleek dark capsule for general list
      textColor = Colors.white;
      scoreColor = const Color(0xffEE5A24);
    }

    Widget trendIcon;
    if (trend == "up") {
      trendIcon = const Icon(Icons.arrow_drop_up_rounded, color: Colors.green, size: 24);
    } else if (trend == "down") {
      trendIcon = const Icon(Icons.arrow_drop_down_rounded, color: Colors.red, size: 24);
    } else {
      trendIcon = const Icon(Icons.horizontal_rule_rounded, color: Colors.grey, size: 14);
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Trend Arrow & Rank Number
          SizedBox(
            width: 44,
            child: Row(
              children: [
                trendIcon,
                Text(
                  rank.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Mini circle avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlightType == "current" || rank <= 3 ? Colors.black.withOpacity(0.15) : const Color(0xff392754),
            ),
            alignment: Alignment.center,
            child: Text(
              avatar,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Player Name
          Expanded(
            child: Text(
              "($name)",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                fontFamily: 'cursive',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Points Score
          Text(
            "$score pts",
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
