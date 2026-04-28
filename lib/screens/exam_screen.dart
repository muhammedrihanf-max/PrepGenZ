import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';
import '../models/exam.dart';

import '../services/exam_service.dart';
import '../services/offline_service.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import '../components/math_text.dart';
import '../components/explanation_text.dart';

class ExamScreen extends StatefulWidget {
  final String year;
  ExamScreen({required this.year});

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  final ExamService _examService = ExamService();
  List<Question>? _questions;
  bool _isLoading = true;
  bool _showExplanation = false;

  // Timer Variables
  Timer? _timer;
  int _remainingSeconds = 120 * 60; // 120 minutes

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _autoSubmitExam();
      }
    });
  }

  void _autoSubmitExam() {
    if (!mounted) return;
    
    final score = (_currentQuestionIndex + 1) * 10; // Placeholder score logic
    _submitToQueue(score);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.amberAccent,
        content: Text('Time is up! Checked Out Offline Queue... Result: $score% 🏆', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
    Navigator.pop(context);
  }

  void _submitToQueue(int score) {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    final attempt = {
      'student_id': auth.user!.id,
      'student_name': auth.user!.userMetadata?['name'] ?? 'Student',
      'exam_name': widget.year,
      'score': score,
      'created_at': DateTime.now().toIso8601String(),
    };
    OfflineService().queueAttemptSync(attempt);
  }

  String _formatTime() {
    final int hours = _remainingSeconds ~/ 3600;
    final int minutes = (_remainingSeconds % 3600) ~/ 60;
    final int seconds = _remainingSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadQuestions() async {
    try {
      final offlineService = OfflineService();
      List<Question>? questions = offlineService.getCachedExam(widget.year);
      
      if (questions == null || questions.isEmpty) {
        questions = await _examService.getQuestionsByYear(widget.year);
        // Explicitly downloading isn't strictly required if they already loaded it online once,
        // but they can manually "Save" from dashboard.
      }
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: GlassTheme.backgroundColor, body: Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor)));
    if (_questions == null || _questions!.isEmpty) return Scaffold(backgroundColor: GlassTheme.backgroundColor, body: Center(child: Text('No questions found.', style: TextStyle(color: Colors.white))));

    final question = _questions![_currentQuestionIndex];
    final bool isLowTime = _remainingSeconds < 300; // Less than 5 minutes red warning

    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('${widget.year} Mock Exam (Preview)', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(icon: Icon(LucideIcons.x, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isLowTime ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isLowTime ? Colors.redAccent : Colors.white24),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: isLowTime ? Colors.redAccent : Colors.white70),
                SizedBox(width: 6),
                Text(
                  _formatTime(),
                  style: TextStyle(
                    color: isLowTime ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ).animate(target: isLowTime ? 1 : 0).shimmer(color: Colors.redAccent.withOpacity(0.3), duration: 1.seconds, curve: Curves.easeInOut),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
            SizedBox(height: 30),
            _buildQuestionCard(question),
            SizedBox(height: 20),
            _buildOptions(question),
            if (_isAnswered && (question.explanation?.isNotEmpty ?? false)) ...[
              SizedBox(height: 16),
              if (!_showExplanation) 
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showExplanation = true),
                    icon: Icon(LucideIcons.helpCircle, size: 16, color: GlassTheme.primaryColor),
                    label: Text('Check Explanation', style: TextStyle(color: GlassTheme.primaryColor)),
                    style: TextButton.styleFrom(
                      backgroundColor: GlassTheme.primaryColor.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              if (_showExplanation) _buildExplanationCard(question.explanation!),
            ],
            SizedBox(height: 40),
            _buildFooter(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQuestionIndex + 1} of ${_questions!.length}', style: TextStyle(color: Colors.white70)),
            Text('Mock Exam Preview', style: TextStyle(color: GlassTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions!.length,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(GlassTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question q) {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MathText(
            q.text,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(Question q) {
    return Column(
      children: q.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final text = entry.value;
        final isSelected = _selectedOption == idx;
        final isCorrect = q.correctAnswer == idx;
        
        Color borderColor = Colors.white24;
        Color glowingColor = Colors.transparent;
        
        if (_isAnswered) {
          if (isCorrect) {
            borderColor = Colors.greenAccent;
            glowingColor = Colors.greenAccent;
          } else if (isSelected && !isCorrect) {
            borderColor = Colors.redAccent;
            glowingColor = Colors.redAccent;
          }
        } else if (isSelected) {
          borderColor = GlassTheme.primaryColor;
        }

        return GestureDetector(
          onTap: _isAnswered ? null : () {
            setState(() {
               _selectedOption = idx;
               _isAnswered = true;
            });
          },
          child: AnimatedContainer(
            duration: 300.ms,
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: glowingColor != Colors.transparent ? [
                BoxShadow(
                  color: glowingColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: GlassTheme.glassWrapper(
              opacity: isSelected ? 0.2 : (isCorrect && _isAnswered ? 0.2 : 0.05),
              borderColor: borderColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                   Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected || (isCorrect && _isAnswered) ? borderColor : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          color: isSelected || (isCorrect && _isAnswered) ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: MathText(text, style: TextStyle(color: Colors.white, fontSize: 14))),
                  if (_isAnswered && (isCorrect || isSelected))
                    Icon(
                      isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                      color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                      size: 20,
                    ),
                ],
              ),
            ),
          ).animate(target: (glowingColor != Colors.transparent) ? 1 : 0).shimmer(color: glowingColor.withOpacity(0.1)),
        );
      }).toList(),
    );
  }

  Widget _buildExplanationCard(String explanation) {
    return GlassTheme.glassWrapper(
      opacity: 0.1,
      padding: EdgeInsets.all(24),
      borderColor: Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, color: Colors.amber, size: 20),
              SizedBox(width: 10),
              Text('Explanation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              IconButton(
                icon: Icon(LucideIcons.chevronUp, color: Colors.white38, size: 16),
                onPressed: () => setState(() => _showExplanation = false),
              ),
            ],
          ),
          SizedBox(height: 12),
          ExplanationText(
            explanation,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isAnswered ? () async {
            if (_currentQuestionIndex < _questions!.length - 1) {
              setState(() {
                _currentQuestionIndex++;
                _selectedOption = null;
                _isAnswered = false;
              });
            } else {
              // Submit exam to the offline queue
              final score = (_currentQuestionIndex + 1) * 10; // Placeholder score logic
              _submitToQueue(score);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exam safely recorded into offline queue! Result: $score% 🏆')),
              );
              Navigator.pop(context);
            }
          } : null,
          child: Text(_currentQuestionIndex < _questions!.length - 1 ? 'Next Question' : 'Finish Exam'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GlassTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
