import 'package:flutter/material.dart';
import 'package:recall_bloom/models/user.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/user_service.dart';
import 'package:recall_bloom/services/study_log_service.dart';
import 'package:recall_bloom/services/revision_schedule_service.dart';
import 'package:recall_bloom/services/streak_service.dart';
import 'package:recall_bloom/widgets/rating_selector.dart';

class AddStudyLogScreen extends StatefulWidget {
  const AddStudyLogScreen({super.key});

  @override
  State<AddStudyLogScreen> createState() => _AddStudyLogScreenState();
}

class _AddStudyLogScreenState extends State<AddStudyLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _timeController = TextEditingController(text: '30');
  
  User? _user;
  String? _selectedSubject;
  int _understandingRating = 3;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final storage = await LocalStorageService.getInstance();
    final userService = UserService(storage);
    final user = await userService.getCurrentUser();
    
    setState(() {
      _user = user;
      _selectedSubject = user?.subjects.first;
      _isLoading = false;
    });
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate() || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final storage = await LocalStorageService.getInstance();
    final studyLogService = StudyLogService(storage);
    final revisionService = RevisionScheduleService(storage);
    final streakService = StreakService(storage);

    await studyLogService.createLog(
      userId: _user!.id,
      topic: _topicController.text.trim(),
      subject: _selectedSubject!,
      timeSpentMinutes: int.parse(_timeController.text),
      understandingRating: _understandingRating,
    );

    final logs = await studyLogService.getLogsByUserId(_user!.id);
    final lastLog = logs.last;

    await revisionService.createScheduleFromLog(lastLog);
    await streakService.updateStreakOnStudyLog(_user!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study log saved! Revision scheduled.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _topicController.clear();
        _timeController.text = '30';
        _understandingRating = 3;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Study Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What did you study?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText: 'e.g., Calculus - Derivatives',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (value) =>
                    value?.trim().isEmpty ?? true ? 'Please enter a topic' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _user!.subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubject = value),
                validator: (value) => value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time Spent (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'Please enter time spent';
                  if (int.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              RatingSelector(
                rating: _understandingRating,
                onRatingChanged: (rating) => setState(() => _understandingRating = rating),
                label: 'How well did you understand?',
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Study Log',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
