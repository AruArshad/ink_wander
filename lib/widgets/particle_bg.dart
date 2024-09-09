import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Color baseColor;
  const ParticleBackground({super.key, required this.baseColor});
  @override
  // ignore: library_private_types_in_public_api
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final int particleCount = 250;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    particles = List.generate(particleCount, (_) => Particle(widget.baseColor));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
              particles: particles, animation: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  late double x, y, size, speed;
  late Color color;
  late String letter;

  Particle(Color baseColor) {
    reset(baseColor);
    y = Random().nextDouble();
  }

  void reset(Color baseColor) {
    x = Random().nextDouble();
    y = 0;
    size = Random().nextDouble() * 12 + 8; // Adjusted size for letters
    speed = Random().nextDouble() * 0.05 + 0.01;
    color = baseColor.withOpacity(Random().nextDouble() * 0.4 + 0.1);
    letter = _getRandomLetter();
  }

  String _getRandomLetter() {
    final random = Random();
    final isUpperCase = random.nextBool();
    final charCode = random.nextInt(26) + (isUpperCase ? 65 : 97);
    return String.fromCharCode(charCode);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y += particle.speed * animation;
      if (particle.y > 1) {
        particle.reset(particle.color);
      }

      final position =
          Offset(particle.x * size.width, particle.y * size.height);

      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.letter,
          style: TextStyle(
            color: particle.color,
            fontSize: particle.size,
            fontWeight: FontWeight.bold, // Added for better visibility
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, position);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
