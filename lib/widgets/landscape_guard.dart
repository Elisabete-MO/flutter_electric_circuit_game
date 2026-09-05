import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'eletrolab_header_brand.dart';

/// Guard widget that checks screen orientation.
/// If the device is in portrait orientation (height > width), displays a prompt
/// asking the user to rotate their device to landscape mode for the best experience.
class LandscapeGuard extends StatefulWidget {
  final Widget child;

  const LandscapeGuard({super.key, required this.child});

  @override
  State<LandscapeGuard> createState() => _LandscapeGuardState();
}

class _LandscapeGuardState extends State<LandscapeGuard> {
  bool _dismissedForSession = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait && media.size.height > media.size.width;

    if (!isPortrait || _dismissedForSession) {
      return widget.child;
    }

    return Stack(
      children: [
        // Background app content (behind guard)
        widget.child,

        // Full screen landscape requirement overlay
        Positioned.fill(
          child: Material(
            color: const Color(0xFB021712),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EletroLabHeaderBrand(),
                    const Spacer(),

                    // Animated / glowing rotation icon container
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0x88032E23),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.screen_rotation_rounded,
                        size: 64,
                        color: Color(0xFF10B981),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Modo Paisagem Recomendado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        'O EletroLab foi desenvolvido para uma experiência imersiva na horizontal. Por favor, gire o seu dispositivo.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Option to continue anyway
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dismissedForSession = true;
                        });
                      },
                      child: Text(
                        'Continuar em modo retrato assim mesmo',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF06B6D4),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
