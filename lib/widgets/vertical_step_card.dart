import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerticalStepCard extends StatelessWidget {
  final dynamic step;
  final bool isActive;
  final bool isLargeScreen;
  const VerticalStepCard({
    required this.step,
    required this.isActive,
    required this.isLargeScreen,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
        ],
      ),
    );
  }
} 