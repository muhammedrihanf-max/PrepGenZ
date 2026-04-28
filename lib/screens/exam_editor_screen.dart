import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../theme/glass_theme.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';
import '../components/math_text.dart';

class ExamEditorScreen extends StatefulWidget {
  final ExamMetadata? exam;

  ExamEditorScreen({this.exam});

  @override
  _ExamEditorScreenState createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends State<ExamEditorScreen> {
  final _examService = ExamService();
  final _idController = TextEditingController();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  
  List<Question> _questions = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      setState(() => _isLoading = true);
      
      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last;
      final fileName = 'exam_images/${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      await Supabase.instance.client.storage
          .from('attachments')
          .uploadBinary(fileName, bytes);
          
      final url = Supabase.instance.client.storage
          .from('attachments')
          .getPublicUrl(fileName);
      
      setState(() => _isLoading = false);
      return url;
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _idController.text = widget.exam!.id;
      _titleController.text = widget.exam!.title;
      _subjectController.text = widget.exam!.subject;
      _gradeController.text = widget.exam!.grade;
      _fetchQuestions();
    } else {
      _questions = [
        Question(
          text: "New Question content...",
          options: ["Option A", "Option B", "Option C", "Option D"],
          correctAnswer: 0,
          explanation: "Explanation goes here...",
        )
      ];
    }
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _examService.getQuestionsByYear(widget.exam!.id);
      setState(() => _questions = questions);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExam() async {
    if (_idController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID and Title are required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _examService.saveExam(
        id: _idController.text,
        title: _titleController.text,
        subject: _subjectController.text,
        grade: _gradeController.text,
        questions: _questions,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exam saved successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving exam: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(Question(
        text: "New Question...",
        options: ["Option A", "Option B", "Option C", "Option D"],
        correctAnswer: 0,
        explanation: "",
        image: null,
        explanationImage: null,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.exam == null ? 'Create Exam' : 'Edit Exam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _saveExam,
              icon: Icon(LucideIcons.save, color: GlassTheme.primaryColor),
              label: Text('Save', style: TextStyle(color: GlassTheme.primaryColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor))
        : SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetadataForm(),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Questions (${_questions.length})', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: Icon(LucideIcons.plus, size: 16),
                      label: Text('Add Question'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlassTheme.primaryColor.withOpacity(0.2),
                        foregroundColor: GlassTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ..._questions.asMap().entries.map((entry) => _buildQuestionEditor(entry.key, entry.value)).toList(),
                SizedBox(height: 100),
              ],
            ),
          ),
    );
  }

  Widget _buildMetadataForm() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField('Exam ID / Year', _idController, 'e.g. 2025', enabled: widget.exam == null),
          SizedBox(height: 16),
          _buildTextField('Exam Title', _titleController, 'e.g. 2025 Mock Examination'),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Subject', _subjectController, 'e.g. Physics')),
              SizedBox(width: 16),
              Expanded(child: _buildTextField('Grade', _gradeController, 'e.g. A/L')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionEditor(int index, Question question) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: GlassTheme.glassWrapper(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(backgroundColor: GlassTheme.primaryColor, radius: 14, child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                IconButton(icon: Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20), onPressed: () => _removeQuestion(index)),
              ],
            ),
            SizedBox(height: 16),
            _buildQuestionTextField('Question Text (supports LaTeX)', (val) {
              setState(() {
                _questions[index] = Question(
                  text: val,
                  options: _questions[index].options,
                  correctAnswer: _questions[index].correctAnswer,
                  explanation: _questions[index].explanation,
                  image: _questions[index].image,
                  explanationImage: _questions[index].explanationImage,
                );
              });
            }, question.text),
            SizedBox(height: 12),
            _buildImagePicker('Question Image', question.image, (url) {
              setState(() {
                _questions[index] = Question(
                  text: _questions[index].text,
                  options: _questions[index].options,
                  correctAnswer: _questions[index].correctAnswer,
                  explanation: _questions[index].explanation,
                  image: url,
                  explanationImage: _questions[index].explanationImage,
                );
              });
            }),
            SizedBox(height: 12),
            // LaTeX Preview
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LaTeX Preview:', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  SizedBox(height: 4),
                  MathText(question.text, style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Options', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...question.options.asMap().entries.map((optEntry) {
              int optIdx = optEntry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Radio<int>(
                      value: optIdx,
                      groupValue: question.correctAnswer,
                      onChanged: (val) {
                        setState(() {
                          _questions[index] = Question(
                            text: question.text,
                            options: question.options,
                            correctAnswer: val!,
                            explanation: question.explanation,
                            image: question.image,
                            explanationImage: question.explanationImage,
                          );
                        });
                      },
                      activeColor: Colors.greenAccent,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          _questions[index].options[optIdx] = val;
                        },
                        controller: TextEditingController(text: optEntry.value)..selection = TextSelection.collapsed(offset: optEntry.value.length),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Option ${String.fromCharCode(65 + optIdx)}',
                          hintStyle: TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: question.options.length > 2 ? IconButton(
                            icon: Icon(LucideIcons.minusCircle, size: 16, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                List<String> newOptions = List.from(question.options);
                                newOptions.removeAt(optIdx);
                                int newCorrect = question.correctAnswer;
                                if (newCorrect >= newOptions.length) newCorrect = newOptions.length - 1;
                                _questions[index] = Question(
                                  text: question.text,
                                  options: newOptions,
                                  correctAnswer: newCorrect,
                                  explanation: question.explanation,
                                  image: question.image,
                                  explanationImage: question.explanationImage,
                                );
                              });
                            },
                          ) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  List<String> newOptions = List.from(question.options);
                  newOptions.add("New Option");
                  _questions[index] = Question(
                    text: question.text,
                    options: newOptions,
                    correctAnswer: question.correctAnswer,
                    explanation: question.explanation,
                    image: question.image,
                    explanationImage: question.explanationImage,
                  );
                });
              },
              icon: Icon(LucideIcons.plusCircle, size: 16, color: GlassTheme.primaryColor),
              label: Text('Add Option', style: TextStyle(color: GlassTheme.primaryColor, fontSize: 12)),
            ),
            SizedBox(height: 16),
            _buildQuestionTextField('Explanation', (val) {
              setState(() {
                _questions[index] = Question(
                  text: _questions[index].text,
                  options: _questions[index].options,
                  correctAnswer: _questions[index].correctAnswer,
                  explanation: val,
                  image: _questions[index].image,
                  explanationImage: _questions[index].explanationImage,
                );
              });
            }, question.explanation ?? ''),
            SizedBox(height: 12),
            _buildImagePicker('Explanation Image', question.explanationImage, (url) {
              setState(() {
                _questions[index] = Question(
                  text: _questions[index].text,
                  options: _questions[index].options,
                  correctAnswer: _questions[index].correctAnswer,
                  explanation: _questions[index].explanation,
                  image: _questions[index].image,
                  explanationImage: url,
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTextField(String label, Function(String) onChanged, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: initialValue)..selection = TextSelection.collapsed(offset: initialValue.length),
          maxLines: null,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String label, String? currentUrl, Function(String?) onImageSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (currentUrl != null && currentUrl.isNotEmpty)
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(currentUrl), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.redAccent, size: 20),
                  onPressed: () => onImageSelected(null),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ],
          ),
        if (currentUrl == null || currentUrl.isEmpty)
          ElevatedButton.icon(
            onPressed: () async {
              final url = await _pickAndUploadImage();
              if (url != null) onImageSelected(url);
            },
            icon: Icon(LucideIcons.image, size: 16),
            label: Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: Colors.white70,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
