import 'package:flutter/material.dart';

import 'activity_controller.dart';
import 'mvp_contract.dart';

class CircuitAnalysisPanel extends StatelessWidget {
  const CircuitAnalysisPanel({
    super.key,
    required this.controller,
  });

  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    final isSwitchClosed = controller.isSwitchClosed;
    final validationStatus = controller.validationStatus;
    final isDiagramCorrect = validationStatus == ValidationStatus.correct;
    final selectedOption = controller.selectedAnalysisOption;
    final isAnswerCorrect = controller.isAnalysisAnswerCorrect;
    final canComplete = isDiagramCorrect && isAnswerCorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info Banner
        Card(
          elevation: 0,
          color: const Color(0xFFF0F9FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBAE6FD), width: 1),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Observe os valores elétricos e selecione a resposta correta para a corrente.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0369A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Value Cards & Questions (Scrollable)
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Voltage Card
              _buildValueCard(
                icon: Icons.bolt,
                iconColor: const Color(0xFFEAB308),
                backgroundColor: const Color(0xFFFEF9C3),
                title: 'Tensão: 6 V',
                subtitle: 'Fonte CC (Bateria)',
              ),
              const SizedBox(height: 8),

              // Resistance Card
              _buildValueCard(
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFF97316),
                backgroundColor: const Color(0xFFFFEDD5),
                title: 'Resistência: 12 Ω',
                subtitle: 'Carga resistiva (Lâmpada)',
              ),
              const SizedBox(height: 10),

              // Ohm's Law Calculator & Question section (Forma mais básica)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lei de Ohm',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSwitchClosed
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSwitchClosed ? 'Fechado' : 'Aberto',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSwitchClosed
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Basic Formula Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'I = V ÷ R',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'I = 6 V ÷ 12 Ω = ?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Qual é o valor da corrente elétrica (I)?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3 Options
                      ...analysisOptions.map((option) {
                        final isSelected = selectedOption == option;
                        final isCorrectOption =
                            option == correctAnalysisOption;

                        Color borderColor = const Color(0xFFCBD5E1);
                        Color bgColor = Colors.white;
                        Widget statusIcon = const Icon(
                          Icons.radio_button_unchecked,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        );
                        String? statusText;

                        if (isSelected) {
                          if (isCorrectOption) {
                            borderColor = const Color(0xFF10B981);
                            bgColor = const Color(0xFFECFDF5);
                            statusIcon = const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            );
                            statusText = 'Correto!';
                          } else {
                            borderColor = const Color(0xFFEF4444);
                            bgColor = const Color(0xFFFEF2F2);
                            statusIcon = const Icon(
                              Icons.cancel,
                              color: Color(0xFFEF4444),
                              size: 20,
                            );
                            statusText = 'Incorreto';
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () =>
                                controller.selectAnalysisOption(option),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected ? 2.0 : 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  statusIcon,
                                  const SizedBox(width: 10),
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected && isCorrectOption
                                          ? const Color(0xFF065F46)
                                          : isSelected && !isCorrectOption
                                              ? const Color(0xFF991B1B)
                                              : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (statusText != null)
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isCorrectOption
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Action Button
        ElevatedButton(
          onPressed: canComplete
              ? () {
                  _showSuccessDialog(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            disabledForegroundColor: const Color(0xFF94A3B8),
            elevation: canComplete ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Concluir atividade',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
              SizedBox(width: 10),
              Text(
                'Parabéns!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Você montou o circuito correto e selecionou a resposta certa da Lei de Ohm (0,5 A)! Atividade concluída com sucesso.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

