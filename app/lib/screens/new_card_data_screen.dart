import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../data/catalog.dart';
import '../data/database.dart' as db;
import 'scan_screen.dart';

/// Videata 8: dati della nuova tessera.
class NewCardDataScreen extends StatefulWidget {
  const NewCardDataScreen({
    super.key,
    required this.database,
    required this.type,
  });

  final db.AppDatabase database;
  final db.CardType type;

  @override
  State<NewCardDataScreen> createState() => _NewCardDataScreenState();
}

class _NewCardDataScreenState extends State<NewCardDataScreen> {
  late final _name = TextEditingController(
    text: hasFixedName(widget.type) ? widget.type.name : '',
  );
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _holder = TextEditingController();
  final _notes = TextEditingController();

  List<db.Section> _sections = const [];
  db.Section? _section;
  int _count = 0;
  DateTime? _expiresOn;
  bool _favorite = false;
  String? _scannedFormat; // formato letto dalla fotocamera, se c'è

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sections = await widget.database.visibleSections();
    final count = await widget.database.activeCardCount();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _section = sections.firstWhere((s) => s.isDefault,
          orElse: () => sections.first);
      _count = count;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _holder.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _scan() async {
    final outcome = await Navigator.of(context).push<ScanOutcome>(
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          typeName: hasFixedName(widget.type) ? widget.type.name : null,
          expectedFormat: widget.type.codeFormat,
        ),
      ),
    );
    if (outcome == null || !mounted) return;
    if (outcome.manual) {
      _codeFocus.requestFocus();
      return;
    }
    final code = outcome.code!;
    setState(() {
      _code.text = code.value;
      _scannedFormat = formatToText(code.format);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 30),
    );
    if (d != null && mounted) setState(() => _expiresOn = d);
  }

  Future<void> _pickSection() async {
    final chosen = await showDialog<db.Section>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sezione'),
        children: [
          for (final s in _sections)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s),
              child: Text(s.name),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) setState(() => _section = chosen);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final code = _code.text.trim();
    final section = _section;
    if (name.isEmpty) return _message('Scrivi il nome della tessera.');
    if (code.isEmpty) return _message('Inserisci o scansiona il codice.');
    if (section == null) return;
    if (_count >= db.AppDatabase.freeCardLimit) {
      return _message('Hai raggiunto il limite di ${db.AppDatabase.freeCardLimit} tessere.');
    }
    // Il formato si salva sempre sulla singola tessera. Scritto a mano e senza
    // formato indicato dalla tipologia: si usa Code 128, che accetta testo libero.
    final format = _scannedFormat ?? widget.type.codeFormat ?? 'code128';
    final holder = _holder.text.trim();
    final notes = _notes.text.trim();
    await widget.database.into(widget.database.cards).insert(
          db.CardsCompanion.insert(
            typeId: widget.type.id,
            name: name,
            code: code,
            codeFormat: format,
            sectionId: section.id,
            holder: Value(holder.isEmpty ? null : holder),
            notes: Value(notes.isEmpty ? null : notes),
            expiresOn: Value(_expiresOn),
            favorite: Value(_favorite),
          ),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final date = _expiresOn;
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  focusNode: _codeFocus,
                  decoration: const InputDecoration(
                    labelText: 'Codice',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _scannedFormat = null,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _scan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scansiona'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Sezione'),
            trailing: Text(_section?.name ?? ''),
            onTap: _pickSection,
          ),
          ListTile(
            title: const Text('Scadenza'),
            trailing: Text(date == null
                ? 'Nessuna'
                : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _holder,
            decoration: const InputDecoration(
              labelText: 'Intestatario',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Facoltative',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aggiungi alle preferite'),
            value: _favorite,
            onChanged: (v) => setState(() => _favorite = v),
          ),
          Text(
            '$_count di ${db.AppDatabase.freeCardLimit} tessere',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Salva')),
        ],
      ),
    );
  }
}
