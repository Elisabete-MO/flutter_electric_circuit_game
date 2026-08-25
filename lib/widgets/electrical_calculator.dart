import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum de modo
// ─────────────────────────────────────────────────────────────────────────────
enum CalculatorMode { ohmsLaw, powerLaw }

// ─────────────────────────────────────────────────────────────────────────────
// Lógica pura (sem estado UI)
// ─────────────────────────────────────────────────────────────────────────────

/// Resultado de um cálculo: qual campo foi calculado e seu valor.
class CalcResult {
  const CalcResult({required this.field, required this.value});
  final String field; // 'V' | 'I' | 'R' | 'P'
  final double value;
}

/// Retorna o campo calculado ou null se não for possível calcular.
CalcResult? calcOhm({double? v, double? i, double? r}) {
  final empty = [if (v == null) 'V', if (i == null) 'I', if (r == null) 'R'];
  if (empty.length != 1) return null; // precisa exatamente de 1 campo vazio
  switch (empty.first) {
    case 'V':
      final result = i! * r!;
      return result.isFinite ? CalcResult(field: 'V', value: result) : null;
    case 'I':
      if (r == 0) return null;
      final result = v! / r!;
      return result.isFinite ? CalcResult(field: 'I', value: result) : null;
    case 'R':
      if (i == 0) return null;
      final result = v! / i!;
      return result.isFinite ? CalcResult(field: 'R', value: result) : null;
    default:
      return null;
  }
}

CalcResult? calcPower({double? p, double? v, double? i}) {
  final empty = [if (p == null) 'P', if (v == null) 'V', if (i == null) 'I'];
  if (empty.length != 1) return null;
  switch (empty.first) {
    case 'P':
      final result = v! * i!;
      return result.isFinite ? CalcResult(field: 'P', value: result) : null;
    case 'V':
      if (i == 0) return null;
      final result = p! / i!;
      return result.isFinite ? CalcResult(field: 'V', value: result) : null;
    case 'I':
      if (v == 0) return null;
      final result = p! / v!;
      return result.isFinite ? CalcResult(field: 'I', value: result) : null;
    default:
      return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────
class ElectricalCalculatorWidget extends StatefulWidget {
  const ElectricalCalculatorWidget({
    super.key,
    this.initialMode = CalculatorMode.ohmsLaw,
  });

  final CalculatorMode initialMode;

  @override
  State<ElectricalCalculatorWidget> createState() =>
      _ElectricalCalculatorWidgetState();
}

class _ElectricalCalculatorWidgetState
    extends State<ElectricalCalculatorWidget> {
  late CalculatorMode _mode;

  // Controladores — compartilhados entre abas onde faz sentido (V, I)
  final _vCtrl = TextEditingController(); // Tensão (compartilhado)
  final _iCtrl = TextEditingController(); // Corrente (compartilhado)
  final _rCtrl = TextEditingController(); // Resistência (Ohm)
  final _pCtrl = TextEditingController(); // Potência (Power)
  final _tCtrl = TextEditingController(); // Tempo em horas (kWh)

  // Qual campo foi calculado por último (para destacar)
  String? _calculatedField;

  // Mensagem de erro de validação
  String? _errorMsg;

  // kWh calculado
  double? _kwhResult;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _vCtrl.dispose();
    _iCtrl.dispose();
    _rCtrl.dispose();
    _pCtrl.dispose();
    _tCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  double? _parse(TextEditingController ctrl) {
    final text = ctrl.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _calculate() {
    setState(() {
      _errorMsg = null;
      _calculatedField = null;
      _kwhResult = null;
    });

    CalcResult? result;

    if (_mode == CalculatorMode.ohmsLaw) {
      final v = _parse(_vCtrl);
      final i = _parse(_iCtrl);
      final r = _parse(_rCtrl);

      result = calcOhm(v: v, i: i, r: r);

      if (result == null) {
        final filled = [v, i, r].where((x) => x != null).length;
        setState(() {
          _errorMsg = filled < 2
              ? 'Preencha pelo menos 2 campos.'
              : filled == 3
                  ? 'Deixe exatamente 1 campo vazio para calcular.'
                  : 'Não foi possível calcular (divisão por zero?).';
        });
        return;
      }

      setState(() {
        _calculatedField = result!.field;
        switch (result.field) {
          case 'V':
            _vCtrl.text = _fmt(result.value);
          case 'I':
            _iCtrl.text = _fmt(result.value);
          case 'R':
            _rCtrl.text = _fmt(result.value);
        }
      });
    } else {
      final p = _parse(_pCtrl);
      final v = _parse(_vCtrl);
      final i = _parse(_iCtrl);

      result = calcPower(p: p, v: v, i: i);

      if (result == null) {
        final filled = [p, v, i].where((x) => x != null).length;
        setState(() {
          _errorMsg = filled < 2
              ? 'Preencha pelo menos 2 campos.'
              : filled == 3
                  ? 'Deixe exatamente 1 campo vazio para calcular.'
                  : 'Não foi possível calcular (divisão por zero?).';
        });
        return;
      }

      setState(() {
        _calculatedField = result!.field;
        switch (result.field) {
          case 'P':
            _pCtrl.text = _fmt(result.value);
          case 'V':
            _vCtrl.text = _fmt(result.value);
          case 'I':
            _iCtrl.text = _fmt(result.value);
        }

        // Calcular kWh se potência e tempo disponíveis
        final finalP = _parse(_pCtrl);
        final t = _parse(_tCtrl);
        if (finalP != null && t != null && t > 0) {
          _kwhResult = finalP * t / 1000;
        }
      });
    }
  }

  void _clear() {
    setState(() {
      _vCtrl.clear();
      _iCtrl.clear();
      _rCtrl.clear();
      _pCtrl.clear();
      _tCtrl.clear();
      _calculatedField = null;
      _errorMsg = null;
      _kwhResult = null;
    });
  }

  String _fmt(double v) {
    // Remove zeros à direita desnecessários
    if (v == v.truncateToDouble()) return v.toInt().toString();
    final s = v.toStringAsFixed(4);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _switchMode(CalculatorMode m) {
    if (_mode == m) return;
    setState(() {
      _mode = m;
      _calculatedField = null;
      _errorMsg = null;
      _kwhResult = null;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF0C1228) : const Color(0xFFF0F4FF);
    final borderColor = EletroLabColors.electricBlue.withValues(alpha: 0.3);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeTabs(isDark),
          const SizedBox(height: 20),
          _buildFields(isDark),
          if (_mode == CalculatorMode.powerLaw) ...[
            const SizedBox(height: 4),
            _buildTimeField(isDark),
          ],
          if (_errorMsg != null) ...[
            const SizedBox(height: 10),
            _buildError(),
          ],
          if (_kwhResult != null) ...[
            const SizedBox(height: 12),
            _buildKwhResult(isDark),
          ],
          const SizedBox(height: 16),
          _buildButtons(isDark),
        ],
      ),
    );
  }

  // ── Abas de Modo ───────────────────────────────────────────────────────────
  Widget _buildModeTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? EletroLabColors.electricBlue.withValues(alpha: 0.06)
            : EletroLabColors.electricBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EletroLabColors.electricBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _modeTab('Lei de Ohm', CalculatorMode.ohmsLaw, isDark),
          _modeTab('Lei da Potência', CalculatorMode.powerLaw, isDark),
        ],
      ),
    );
  }

  Widget _modeTab(String label, CalculatorMode m, bool isDark) {
    final selected = _mode == m;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? EletroLabColors.electricBlue.withValues(alpha: isDark ? 0.25 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              letterSpacing: 0.8,
              color: selected
                  ? EletroLabColors.electricBlue
                  : (isDark
                      ? Colors.white54
                      : Colors.black45),
            ),
          ),
        ),
      ),
    );
  }

  // ── Campos por modo ────────────────────────────────────────────────────────
  Widget _buildFields(bool isDark) {
    if (_mode == CalculatorMode.ohmsLaw) {
      return Column(
        children: [
          _buildField('Tensão', 'V', 'Volts (V)', _vCtrl, isDark),
          const SizedBox(height: 10),
          _buildField('Corrente', 'I', 'Ampères (A)', _iCtrl, isDark),
          const SizedBox(height: 10),
          _buildField('Resistência', 'R', 'Ohms (Ω)', _rCtrl, isDark),
        ],
      );
    } else {
      return Column(
        children: [
          _buildField('Potência', 'P', 'Watts (W)', _pCtrl, isDark),
          const SizedBox(height: 10),
          _buildField('Tensão', 'V', 'Volts (V)', _vCtrl, isDark),
          const SizedBox(height: 10),
          _buildField('Corrente', 'I', 'Ampères (A)', _iCtrl, isDark),
        ],
      );
    }
  }

  Widget _buildField(
    String label,
    String fieldKey,
    String unit,
    TextEditingController ctrl,
    bool isDark,
  ) {
    final isResult = _calculatedField == fieldKey;
    final accentColor = isResult ? EletroLabColors.neonGreen : EletroLabColors.electricBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            if (isResult) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: EletroLabColors.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: EletroLabColors.neonGreen.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'CALCULADO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: EletroLabColors.neonGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isResult
                ? EletroLabColors.neonGreen
                : (isDark ? Colors.white : Colors.black87),
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: '?',
            hintStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.18),
            ),
            suffixText: unit,
            suffixStyle: TextStyle(
              fontSize: 12,
              color: accentColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: isResult
                ? EletroLabColors.neonGreen.withValues(alpha: isDark ? 0.08 : 0.05)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isResult
                    ? EletroLabColors.neonGreen.withValues(alpha: 0.6)
                    : accentColor.withValues(alpha: 0.2),
                width: isResult ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: accentColor.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
          ),
          onSubmitted: (_) => _calculate(),
          onChanged: (_) {
            // Se o usuário edita o campo calculado, remove o destaque
            if (_calculatedField == fieldKey) {
              setState(() => _calculatedField = null);
            }
          },
        ),
      ],
    );
  }

  // ── Campo de Tempo (kWh) ───────────────────────────────────────────────────
  Widget _buildTimeField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Tempo de uso',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _tCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: GoogleFonts.rajdhani().fontFamily,
          ),
          decoration: InputDecoration(
            hintText: 'Informe as horas',
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            suffixText: 'Horas',
            suffixStyle: TextStyle(
              fontSize: 12,
              color: EletroLabColors.amber.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: EletroLabColors.amber.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: EletroLabColors.amber.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Erro ───────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EletroLabColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EletroLabColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 14, color: EletroLabColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMsg!,
              style: TextStyle(
                fontSize: 12,
                color: EletroLabColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Resultado kWh ──────────────────────────────────────────────────────────
  Widget _buildKwhResult(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EletroLabColors.amber.withValues(alpha: isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: EletroLabColors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONSUMO ENERGETICO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_fmt(_kwhResult!)} kWh',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  color: EletroLabColors.amber,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${_tCtrl.text.trim()} h',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  // ── Botões ─────────────────────────────────────────────────────────────────
  Widget _buildButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_rounded, size: 18),
            label: const Text('Calcular'),
            style: FilledButton.styleFrom(
              backgroundColor: EletroLabColors.electricBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              textStyle: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Limpar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white60 : Colors.black54,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
              textStyle: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}