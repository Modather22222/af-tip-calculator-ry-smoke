import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TipCalculatorApp());
}

class TipCalculatorApp extends StatelessWidget {
  const TipCalculatorApp({super.key});

  static const Color _seed = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    final InputDecorationTheme inputTheme = InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(width: 2),
      ),
    );

    return MaterialApp(
      title: 'Tip Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        inputDecorationTheme: inputTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: inputTheme,
      ),
      home: const TipCalculatorPage(),
    );
  }
}

class TipCalculatorPage extends StatefulWidget {
  const TipCalculatorPage({super.key});

  @override
  State<TipCalculatorPage> createState() => _TipCalculatorPageState();
}

class _TipCalculatorPageState extends State<TipCalculatorPage> {
  static const double _maxTip = 40;
  static const int _maxPeople = 20;

  final TextEditingController _billController = TextEditingController(
    text: '42.00',
  );

  double _tipPercent = 18;
  int _people = 3;
  int _payer = 0;

  double get _bill => double.tryParse(_billController.text) ?? 0;
  double get _tipAmount => _bill * _tipPercent / 100;
  double get _total => _bill + _tipAmount;
  double get _perPerson => _total / _people;

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  void _setPeople(int value) {
    final int next = value.clamp(1, _maxPeople).toInt();
    setState(() {
      _people = next;
      if (_payer >= next) {
        _payer = 0;
      }
    });
  }

  void _reset() {
    _billController.text = '42.00';
    setState(() {
      _tipPercent = 18;
      _people = 3;
      _payer = 0;
    });
  }

  List<int> get _sortedPeople {
    final List<int> people = List<int>.generate(_people, (int index) => index);
    people.sort((int a, int b) {
      final int aRank = a == _payer ? 0 : 1;
      final int bRank = b == _payer ? 0 : 1;
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.compareTo(b);
    });
    return people;
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
        title: const Text(
          'Tip Calculator',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: <Widget>[
                _buildTotalCard(scheme, text),
                const SizedBox(height: 16),
                _buildBillCard(scheme, text),
                const SizedBox(height: 16),
                _buildSplitCard(scheme, text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(ColorScheme scheme, TextTheme text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.groups_2_outlined,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Each person pays',
                  style: text.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Person ${_payer + 1} pays',
                  style: text.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _money(_perPerson),
            style: text.displayMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_money(_tipAmount)} tip  •  ${_money(_total)} total',
            style: text.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(ColorScheme scheme, TextTheme text) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Bill amount',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _billController,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[
              TextInputFormatter.withFunction((
                TextEditingValue oldValue,
                TextEditingValue newValue,
              ) {
                final String value = newValue.text;
                if (value.isEmpty ||
                    RegExp(r'^\d*\.?\d{0,2}$').hasMatch(value)) {
                  return newValue;
                }
                return oldValue;
              }),
            ],
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              prefixStyle: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Tip percentage',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_tipPercent.round()}%',
                  style: text.titleSmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _tipPercent,
            min: 0,
            max: _maxTip,
            divisions: _maxTip.toInt(),
            label: '${_tipPercent.round()}%',
            onChanged: (double value) {
              setState(() => _tipPercent = value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('0%', style: text.bodySmall),
                Text('20%', style: text.bodySmall),
                Text('40%', style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitCard(ColorScheme scheme, TextTheme text) {
    final List<int> people = _sortedPeople;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  color: scheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Split the bill',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_people ${_people == 1 ? 'person' : 'people'}',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _PeopleStepper(
                people: _people,
                onDecrease: _people > 1 ? () => _setPeople(_people - 1) : null,
                onIncrease: _people < _maxPeople
                    ? () => _setPeople(_people + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Who pays?',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a person to mark who settles the bill. The payer is shown first.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ...people.map(
            (int person) =>
                _buildPersonRow(person: person, scheme: scheme, text: text),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonRow({
    required int person,
    required ColorScheme scheme,
    required TextTheme text,
  }) {
    final bool isPayer = person == _payer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isPayer
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _payer = person),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isPayer ? scheme.primary : scheme.surface,
                  foregroundColor: isPayer
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  child: Text(
                    '${person + 1}',
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Person ${person + 1}',
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isPayer
                              ? scheme.onSecondaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                      if (isPayer)
                        Text(
                          'Paying the bill',
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _money(_perPerson),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPayer
                        ? scheme.onSecondaryContainer
                        : scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isPayer ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 20,
                  color: isPayer ? scheme.onSecondaryContainer : scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: child,
    );
  }
}

class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({
    required this.people,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int people;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Remove a person',
            onPressed: onDecrease,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove_rounded, size: 20),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$people',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Add a person',
            onPressed: onIncrease,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
