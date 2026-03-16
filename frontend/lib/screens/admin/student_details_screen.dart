import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({super.key});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiService.getAllStudents();
      if (!mounted) return;
      final data = response['data'] as List? ?? [];
      setState(() {
        _students = data.map((s) => Map<String, dynamic>.from(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final studentId = (s['studentId'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || studentId.contains(q) || email.contains(q);
    }).toList();
  }

  void _showResetPasswordDialog(Map<String, dynamic> student) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password for ${student['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Student ID: ${student['studentId']}',
                style: const TextStyle(color: AppTheme.mutedGrey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              try {
                await ApiService.resetStudentPassword(
                  student['id'].toString(),
                  controller.text,
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Password reset successfully')),
                );
                _loadStudents(); // Refresh
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Failed: $e')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error!, style: const TextStyle(color: AppTheme.mutedGrey)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadStudents, child: const Text('Retry')),
                  ]),
                )
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name, ID, or email...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),

                    // Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        Text(
                          '${_filteredStudents.length} students',
                          style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.mutedGrey),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _copyAllCredentials(),
                          icon: const Icon(Icons.copy_all, size: 18),
                          label: const Text('Copy All'),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 8),

                    // Student List
                    Expanded(
                      child: _filteredStudents.isEmpty
                          ? const Center(
                              child: Text('No students found', style: TextStyle(color: AppTheme.mutedGrey)),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadStudents,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _filteredStudents[index];
                                  return _buildStudentCard(student, index + 1);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int number) {
    final name = student['name'] ?? 'Unknown';
    final studentId = student['studentId'] ?? 'N/A';
    final email = student['email'] ?? 'N/A';
    final password = student['password'] ?? studentId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withAlpha(25),
          child: Text('$number', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('ID: $studentId', style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _detailRow('Student ID', studentId, () => _copyToClipboard(studentId, 'Student ID')),
                _detailRow('Email', email, email != 'N/A' ? () => _copyToClipboard(email, 'Email') : null),
                _detailRow('Password', password, () => _copyToClipboard(password, 'Password')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(
                        'ID: $studentId\nPassword: $password',
                        'Credentials',
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Credentials', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetPasswordDialog(student),
                      icon: const Icon(Icons.lock_reset, size: 16),
                      label: const Text('Reset Password', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, VoidCallback? onCopy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: AppTheme.mutedGrey),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ]),
    );
  }

  void _copyAllCredentials() {
    final buffer = StringBuffer();
    buffer.writeln('Student Credentials');
    buffer.writeln('=' * 40);
    for (final s in _filteredStudents) {
      final name = s['name'] ?? 'Unknown';
      final studentId = s['studentId'] ?? 'N/A';
      final password = s['password'] ?? studentId;
      buffer.writeln('Name: $name');
      buffer.writeln('Student ID: $studentId');
      buffer.writeln('Password: $password');
      buffer.writeln('-' * 30);
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All ${_filteredStudents.length} student credentials copied!')),
    );
  }
}
