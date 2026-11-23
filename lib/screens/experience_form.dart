import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  static const List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Magang',
    'Freelance',
    'Kontrak',
  ];

  String? _employmentType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  String? _validateRequiredText(String? value, String label, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong';
    if (text.length > maxLength) {
      return '$label maksimal $maxLength karakter';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return valid ? null : 'Masukkan URL valid, contoh: https://perusahaan.com';
  }

  String? _validateEndDate(String? value) {
    if (_isCurrent) return null;
    if (_endDate == null) return 'Pilih tanggal selesai';
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengalaman Tersimpan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryRow('Perusahaan', _companyController.text.trim()),
              _summaryRow('Posisi', _positionController.text.trim()),
              _summaryRow('Jenis', _employmentType ?? '-'),
              _summaryRow('Mulai', _formatDate(_startDate!)),
              _summaryRow(
                'Selesai',
                _isCurrent ? 'Masih bekerja' : _formatDate(_endDate!),
              ),
              _summaryRow('Deskripsi', _descriptionController.text.trim()),
              _summaryRow(
                'URL',
                _urlController.text.trim().isEmpty
                    ? '-'
                    : _urlController.text.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Tambah Pengalaman')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _companyController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama Perusahaan',
                  hintText: 'Contoh: PT Teknologi Nusantara',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    _validateRequiredText(v, 'Nama perusahaan', 100),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Posisi',
                  hintText: 'Contoh: Mobile Developer Intern',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequiredText(v, 'Posisi', 100),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _employmentType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Pekerjaan',
                  border: OutlineInputBorder(),
                ),
                items: _employmentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _employmentType = v),
                validator: (v) => v == null ? 'Pilih jenis pekerjaan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () => _pickDate(isStart: true),
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (_) =>
                    _startDate == null ? 'Pilih tanggal mulai' : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Masih bekerja di sini'),
                value: _isCurrent,
                onChanged: (v) => setState(() {
                  _isCurrent = v;
                  if (v) {
                    _endDate = null;
                    _endDateController.clear();
                  }
                }),
              ),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                enabled: !_isCurrent,
                onTap: () => _pickDate(isStart: false),
                decoration: const InputDecoration(
                  labelText: 'Tanggal Selesai',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEndDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequiredText(v, 'Deskripsi', 500),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL Perusahaan (opsional)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
