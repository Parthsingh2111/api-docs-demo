import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedStepCard extends StatelessWidget {
  final dynamic step;
  final bool isActive;
  final bool isLargeScreen;
  final bool showNext;
  final bool showBack;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String buttonLabel;
  final bool showPayloadAnim;
  final String payloadLabel;
  final Color payloadColor;
  const AnimatedStepCard({
    super.key,
    required this.step,
    required this.isActive,
    required this.isLargeScreen,
    required this.showNext,
    required this.showBack,
    required this.onNext,
    required this.onBack,
    required this.buttonLabel,
    required this.showPayloadAnim,
    required this.payloadLabel,
    required this.payloadColor,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        padding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 18 : 12,
          horizontal: isLargeScreen ? 32 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
          border: Border.all(
            color: isActive ? Colors.deepPurple : Colors.grey.shade200,
            width: isActive ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPayloadAnim)
              AnimatedSlide(
                offset: isActive ? Offset.zero : const Offset(0, -0.2),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: isLargeScreen ? 80 : 60,
                    height: isLargeScreen ? 48 : 36,
                    decoration: BoxDecoration(
                      color: payloadColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: payloadColor.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        payloadLabel,
                        style: GoogleFonts.poppins(
                          fontSize: isLargeScreen ? 16 : 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Icon(step.icon, color: Colors.deepPurple, size: isLargeScreen ? 32 : 22),
                const SizedBox(width: 16),
                Text(
                  step.title,
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 20 : 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: GoogleFonts.notoSans(
                fontSize: isLargeScreen ? 15 : 12,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                step.pseudocode,
                style: GoogleFonts.robotoMono(
                  fontSize: isLargeScreen ? 14 : 11,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            if (step.dataTitle != null && step.dataContent != null) ...[
              const SizedBox(height: 10),
              Text(
                step.dataTitle!,
                style: GoogleFonts.notoSans(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  step.dataContent!,
                  style: GoogleFonts.robotoMono(
                    fontSize: isLargeScreen ? 13 : 10,
                    color: Colors.teal.shade900,
                  ),
                ),
              ),
            ],
            if (step.function != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.code, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text(
                      step.function!,
                      style: GoogleFonts.robotoMono(
                        fontSize: isLargeScreen ? 13 : 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            if (step.endpoint != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 4),
                    Text(
                      step.endpoint!,
                      style: GoogleFonts.robotoMono(
                        fontSize: isLargeScreen ? 13 : 10,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showBack)
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                  ),
                if (showNext)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_downward),
                      label: Text(buttonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 