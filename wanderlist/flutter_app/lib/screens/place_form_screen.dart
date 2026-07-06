import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/place.dart';
import '../models/rating.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/star_rating.dart';

class PlaceFormScreen extends ConsumerStatefulWidget {
  final int? cityId;
  final int? placeId;
  const PlaceFormScreen({super.key, this.cityId, this.placeId});

  @override
  ConsumerState<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends ConsumerState<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  Place? _existing;

  String _type = 'food';
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _category = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _note = TextEditingController();
  String? _tag;
  String? _dateVisited;

  Map<String, double?> _rating = {
    'quality': null, 'quantity': null, 'price': null,
    'service': null, 'cleanliness': null, 'beauty': null, 'cost': null,
  };

  static const _foodTags = ['Colazione','Brunch','Pranzo','Pranzo veloce','Merenda','Aperitivo','Cena','Dopocena'];
  static const _visitCats = ['Musei','Chiese','Monumenti','Spiagge','Piscine','Parchi','Borgo','Arte','Natura'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.placeId != null) {
      final user = ref.read(authProvider).valueOrNull;
      final p = await ref.read(repositoryProvider).getPlace(widget.placeId!, currentUser: user?.username);
      if (p != null && mounted) {
        _existing = p;
        _type = p.type;
        _name.text = p.name;
        _address.text = p.address ?? '';
        _category.text = p.category ?? '';
        _lat.text = p.lat?.toString() ?? '';
        _lng.text = p.lng?.toString() ?? '';
        _note.text = p.note ?? '';
        _tag = p.tag;
        _dateVisited = p.dateVisited;
        final r = p.ratingFor(user?.username ?? '');
        if (r != null) {
          _rating = {
            'quality': r.quality, 'quantity': r.quantity, 'price': r.price,
            'service': r.service, 'cleanliness': r.cleanliness,
            'beauty': r.beauty, 'cost': r.cost,
          };
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose(); _address.dispose(); _category.dispose();
    _lat.dispose(); _lng.dispose(); _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(_existing != null ? 'Modifica posto' : 'Aggiungi posto'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _submit(user?.username),
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Salva', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.terra)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Type toggle
                  _TypeToggle(selected: _type, onSelect: (t) => setState(() { _type = t; _category.clear(); _tag = null; })),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
                  ),
                  const SizedBox(height: 12),

                  // Address
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Indirizzo', prefixIcon: Icon(Icons.location_on_outlined, size: 18)),
                  ),
                  const SizedBox(height: 12),

                  // Lat / Lng
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _lat,
                      decoration: const InputDecoration(labelText: 'Latitudine'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(
                      controller: _lng,
                      decoration: const InputDecoration(labelText: 'Longitudine'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    )),
                  ]),
                  const SizedBox(height: 12),

                  // Category
                  if (_type == 'food')
                    TextFormField(
                      controller: _category,
                      decoration: const InputDecoration(labelText: 'Categoria (es. Pizzeria, Wine Bar…)'),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _visitCats.contains(_category.text) ? _category.text : null,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _visitCats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category.text = v ?? ''),
                    ),
                  const SizedBox(height: 12),

                  // Tag (food only)
                  if (_type == 'food')
                    DropdownButtonFormField<String>(
                      value: _tag,
                      decoration: const InputDecoration(labelText: 'Momento'),
                      items: [const DropdownMenuItem(value: null, child: Text('— Nessuno —')),
                        ..._foodTags.map((t) => DropdownMenuItem(value: t, child: Text(t)))],
                      onChanged: (v) => setState(() => _tag = v),
                    ),
                  if (_type == 'food') const SizedBox(height: 12),

                  // Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _dateVisited = picked.toIso8601String().substring(0, 10));
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Data visita', prefixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                      child: Text(_dateVisited ?? 'Seleziona data',
                        style: TextStyle(color: _dateVisited == null ? Colors.grey : AppTheme.inkColor, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Note
                  TextFormField(
                    controller: _note,
                    decoration: const InputDecoration(labelText: 'Note / impressioni'),
                    maxLines: 3,
                  ),

                  // Rating section
                  if (user != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.paperDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Il tuo voto ${user.username == "luchino" ? "🧑" : "👩"}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          ...(_type == 'food'
                            ? [('Qualità', 'quality'), ('Quantità', 'quantity'), ('Prezzo', 'price'), ('Servizio', 'service'), ('Pulizia', 'cleanliness')]
                            : [('Bellezza', 'beauty'), ('Costo', 'cost')]
                          ).map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Expanded(child: Text(f.$1, style: const TextStyle(fontSize: 13))),
                              StarInput(
                                value: _rating[f.$2],
                                onChange: (v) => setState(() => _rating[f.$2] = v),
                              ),
                            ]),
                          )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Future<void> _submit(String? username) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = ref.read(repositoryProvider);
      final lat = double.tryParse(_lat.text);
      final lng = double.tryParse(_lng.text);
      final cat = _category.text.trim().isEmpty ? null : _category.text.trim();

      Place saved;
      if (_existing != null) {
        final updated = _existing!.copyWith(
          type: _type, name: _name.text.trim(), address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          category: cat, tag: _tag, lat: lat, lng: lng,
          dateVisited: _dateVisited, note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
        saved = await repo.updatePlace(updated);
      } else {
        saved = await repo.insertPlace(Place.create(
          cityId: widget.cityId!,
          type: _type,
          name: _name.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          category: cat, tag: _tag, lat: lat, lng: lng,
          dateVisited: _dateVisited,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          createdBy: username,
        ));
      }

      // Save rating if user is logged in and any value set
      if (username != null && _rating.values.any((v) => v != null)) {
        final existingR = _existing?.ratingFor(username);
        final rating = existingR != null
            ? existingR.copyWith(
                quality: _rating['quality'], quantity: _rating['quantity'],
                price: _rating['price'], service: _rating['service'],
                cleanliness: _rating['cleanliness'], beauty: _rating['beauty'],
                cost: _rating['cost'],
              )
            : Rating.create(
                placeId: saved.id!,
                user: username,
                quality: _rating['quality'], quantity: _rating['quantity'],
                price: _rating['price'], service: _rating['service'],
                cleanliness: _rating['cleanliness'], beauty: _rating['beauty'],
                cost: _rating['cost'],
              );
        await repo.upsertRating(rating);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  const _TypeToggle({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperDark,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _Btn('food', '🍽️  Mangiare & Bere', selected, onSelect),
        _Btn('visit', '🗺️  Da Visitare', selected, onSelect),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String value, label, selected;
  final void Function(String) onSelect;
  const _Btn(this.value, this.label, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected == value ? AppTheme.terra : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: selected == value ? Colors.white : AppTheme.inkLight,
          ),
        ),
      ),
    ),
  );
}
