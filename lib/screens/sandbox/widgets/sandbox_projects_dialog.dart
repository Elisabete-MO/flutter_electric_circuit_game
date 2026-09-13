import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sandbox_state.dart';
import '../../../services/sandbox_persistence_repository.dart';
import '../../../widgets/glass_container.dart';

class SandboxProjectsDialog extends StatefulWidget {
  final SandboxState currentState;
  final bool isEn;
  final bool isDark;
  final List<SavedProjectSummary> projects;
  final Future<void> Function(String name) onSaveCurrent;
  final Function(String id) onLoadProject;
  final Future<void> Function(String id) onDeleteProject;

  const SandboxProjectsDialog({
    super.key,
    required this.currentState,
    required this.isEn,
    required this.isDark,
    required this.projects,
    required this.onSaveCurrent,
    required this.onLoadProject,
    required this.onDeleteProject,
  });

  @override
  State<SandboxProjectsDialog> createState() => _SandboxProjectsDialogState();
}

class _SandboxProjectsDialogState extends State<SandboxProjectsDialog> {
  final TextEditingController _nameController = TextEditingController();
  late List<SavedProjectSummary> _projectList;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _projectList = List.from(widget.projects);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    await widget.onSaveCurrent(name);
    _nameController.clear();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEn ? 'Circuit "$name" saved!' : 'Circuito "$name" salvo com sucesso!',
          ),
          backgroundColor: const Color(0xFF047857),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;
    final isDark = widget.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        borderRadius: 20,
        opacity: isDark ? 0.88 : 0.95,
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00F5D4), width: 1.5),
                    ),
                    child: const Icon(Icons.folder_special_rounded, color: Color(0xFF00F5D4), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'SAVED CIRCUITS & PROJECTS' : 'PROJETOS & CIRCUITOS SALVOS',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          isEn ? 'Save, load and manage your custom circuits' : 'Salve, carregue e gerencie seus circuitos',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 14),

              // Seção Salvar Circuito Atual
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.save_as_rounded, size: 16, color: Color(0xFF00F5D4)),
                        const SizedBox(width: 6),
                        Text(
                          isEn ? 'Save current circuit' : 'Salvar circuito atual',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.currentState.components.length} peças • ${widget.currentState.wires.length} fios',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF00F5D4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: isEn ? 'Enter project name...' : 'Nome do projeto (ex: Alarme LDR)...',
                                hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isEn ? 'Save' : 'Salvar',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Título Lista de Projetos
              Text(
                isEn ? 'Saved Projects (${_projectList.length})' : 'Projetos Salvos (${_projectList.length})',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Lista de Projetos Salvos
              Expanded(
                child: _projectList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 36, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              isEn
                                  ? 'No saved projects yet.\nSave your current circuit above!'
                                  : 'Nenhum projeto salvo ainda.\nSalve seu circuito atual acima!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _projectList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final project = _projectList[index];
                          final date = DateTime.fromMillisecondsSinceEpoch(project.updatedAtMs);
                          final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.memory_rounded, size: 20, color: Color(0xFF00FF9D)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${project.componentCount} peças • ${project.wireCount} fios • $dateStr',
                                        style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20, color: Color(0xFF00F5D4)),
                                  tooltip: isEn ? 'Load Project' : 'Carregar Projeto',
                                  onPressed: () {
                                    widget.onLoadProject(project.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B7F)),
                                  tooltip: isEn ? 'Delete' : 'Excluir',
                                  onPressed: () async {
                                    await widget.onDeleteProject(project.id);
                                    setState(() {
                                      _projectList.removeWhere((p) => p.id == project.id);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // Botão Fechar
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isEn ? 'Close' : 'Fechar',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
