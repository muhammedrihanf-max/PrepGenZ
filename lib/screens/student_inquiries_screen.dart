import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/glass_theme.dart';
import '../services/support_service.dart';
import '../services/auth_provider.dart';

class StudentInquiriesScreen extends StatefulWidget {
  @override
  _StudentInquiriesScreenState createState() => _StudentInquiriesScreenState();
}

class _StudentInquiriesScreenState extends State<StudentInquiriesScreen> {
  final SupportService _supportService = SupportService();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isStudent = auth.role == 'student';

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isStudent),
          if (isStudent) ...[
            _buildSupportInfoBox(),
            SizedBox(height: 30),
            _buildQuestionForm(auth),
            SizedBox(height: 40),
            _buildInquiryHistoryHeader(),
            SizedBox(height: 20),
          ],
          _buildInquiryList(auth, isStudent),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isStudent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.helpCircle, color: GlassTheme.primaryColor, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                isStudent ? 'Raise a Question' : 'Student Inquiries',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          isStudent ? 'Facing difficulties? Ask your teacher directly.' : 'Respond to student questions and support requests',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSupportInfoBox() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: GlassTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text('Technical Support & Author', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          _supportInfoItem(LucideIcons.user, 'Muhammed Rihan'),
          _supportInfoItem(LucideIcons.phone, '+971566202782'),
          _supportInfoItem(LucideIcons.mail, 'muhammedrihanf@gmail.com'),
          SizedBox(height: 8),
          Text(
            'Muhammed Rihan is the author and developer of PrepGenZ.',
            style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _supportInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 14),
          SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQuestionForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        if (_selectedImage != null)
          Container(
            margin: EdgeInsets.only(bottom: 12),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: MemoryImage(_imageBytes!), 
                fit: BoxFit.cover
              ),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => setState(() => _selectedImage = null),
              ),
            ),
          ),
        TextField(
          controller: _questionController,
          maxLines: 6,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your question here in detail...',
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  setState(() {
                    _selectedImage = image;
                    _imageBytes = bytes;
                  });
                }
              },
              icon: Icon(LucideIcons.image, size: 18),
              label: Text('Attach a Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : () => _sendQuestion(auth),
                icon: _isSending ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(LucideIcons.send, size: 18),
                label: Text('Send to Teacher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlassTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Your teacher will be notified immediately and usually responds within 24 hours.',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
      ],
    );
  }

  Future<void> _sendQuestion(AuthProvider auth) async {
    if (_questionController.text.trim().isEmpty && _selectedImage == null) return;
    
    setState(() => _isSending = true);
    try {
      String? attachmentUrl;

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final ext = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        await Supabase.instance.client.storage
            .from('attachments')
            .uploadBinary(fileName, bytes);
            
        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(fileName);
      }

      await _supportService.createInquiry(
        studentId: auth.user!.id,
        studentName: auth.user!.userMetadata?['name'] ?? 'Student',
        fromPhoto: auth.user!.userMetadata?['photo_url'],
        message: _questionController.text.trim(),
        attachment: attachmentUrl,
      );
      _questionController.clear();
      if (mounted) setState(() => _selectedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Question sent successfully! 🚀')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send question: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildInquiryHistoryHeader() {
    return Row(
      children: [
        Icon(LucideIcons.clock, color: Colors.white24, size: 18),
        SizedBox(width: 8),
        Text('Inquiry History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInquiryList(AuthProvider auth, bool isStudent) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supportService.subscribeToInquiries(auth.user!.id, auth.user!.appMetadata['role'] ?? 'student'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
        }
        final inquiries = snapshot.data ?? [];
        if (inquiries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No past inquiries found.', style: TextStyle(color: Colors.white24)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = inquiries[index];
            final reply = inquiry['reply'];
            final isReplied = reply != null;
            final status = inquiry['status'] ?? (isReplied ? 'replied' : 'open');

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: GlassTheme.glassWrapper(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12, 
                              backgroundColor: GlassTheme.primaryColor.withOpacity(0.2), 
                              backgroundImage: (inquiry['from_photo'] != null && inquiry['from_photo'].isNotEmpty) ? NetworkImage(inquiry['from_photo']) : null,
                              child: (inquiry['from_photo'] == null || inquiry['from_photo'].isEmpty) ? Text(inquiry['from_name']?[0] ?? 'S', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)) : null,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(inquiry['from_name'] ?? 'Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isReplied ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(color: isReplied ? Colors.greenAccent : Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (inquiry['message'] != null && inquiry['message'].toString().isNotEmpty)
                      Text(inquiry['message'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                    if (inquiry['attachment'] != null && inquiry['attachment'].toString().isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: NetworkImage(inquiry['attachment']), fit: BoxFit.cover),
                        ),
                      ),
                    if (isReplied) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: GlassTheme.primaryColor.withOpacity(0.2),
                                  backgroundImage: (reply['author_photo'] != null && reply['author_photo'].toString().isNotEmpty) ? NetworkImage(reply['author_photo']) : null,
                                  child: (reply['author_photo'] == null || reply['author_photo'].toString().isEmpty) ? Icon(LucideIcons.user, size: 10, color: Colors.white60) : null,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Replied by ${reply['author']}', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(reply['message'], style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                    ] else if (!isStudent) ...[
                      SizedBox(height: 20),
                      Divider(color: Colors.white10),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Write your response...',
                                hintStyle: TextStyle(color: Colors.white24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                fillColor: Colors.white.withOpacity(0.05),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(LucideIcons.send, color: GlassTheme.primaryColor),
                            onPressed: () async {
                              if (_replyController.text.trim().isEmpty) return;
                              final name = auth.user!.userMetadata?['name'] ?? 'Instructor';
                              try {
                                await _supportService.replyToInquiry(
                                  inquiry['id'].toString(), 
                                  _replyController.text.trim(), 
                                  name,
                                  auth.user!.userMetadata?['photo_url'],
                                );
                                _replyController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Reply sent! ✅')));
                                }
                              } catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
