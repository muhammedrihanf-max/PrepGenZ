import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';
import 'exam_editor_screen.dart';
import 'exam_screen.dart';

class ManageExamsScreen extends StatefulWidget {
  @override
  _ManageExamsScreenState createState() => _ManageExamsScreenState();
}

class _ManageExamsScreenState extends State<ManageExamsScreen> {
  final _examService = ExamService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Exams', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('Create and edit mock examinations', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.plusCircle, color: GlassTheme.primaryColor, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExamEditorScreen()),
                  );
                },
              )
            ],
          ),
          SizedBox(height: 30),
          _buildExamList(),
        ],
      ),
    );
  }

  Widget _buildExamList() {
    return StreamBuilder<List<ExamMetadata>>(
      stream: _examService.subscribeToExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.redAccent)));
        }

        final exams = snapshot.data ?? [];
        
        if (exams.isEmpty) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Icon(LucideIcons.fileX, color: Colors.white12, size: 64),
                SizedBox(height: 16),
                Text('No exams found', style: TextStyle(color: Colors.white38)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: GlassTheme.glassWrapper(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.fileText, color: Colors.white70),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${exam.questionCount} Questions • ${exam.subject} • ${exam.grade}', style: TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.eye, color: Colors.white38, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExamScreen(year: exam.id)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.edit3, color: Colors.white38, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExamEditorScreen(exam: exam)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.trash2, color: Colors.redAccent.withOpacity(0.5), size: 20),
                      onPressed: () => _confirmDelete(exam),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(ExamMetadata exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        title: Text('Delete Exam', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${exam.title}"? This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white38)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _examService.deleteExam(exam.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exam deleted successfully')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting exam: $e')));
              }
            },
          ),
        ],
      ),
    );
  }
}
