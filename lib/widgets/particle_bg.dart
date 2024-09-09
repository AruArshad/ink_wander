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
  final int particleCount = 250; // Reduced particle count

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10)) // Increased duration
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
  late ShapeType shape;

  Particle(Color baseColor) {
    reset(baseColor);
    y = Random().nextDouble();
  }

  void reset(Color baseColor) {
    x = Random().nextDouble();
    y = 0;
    size = Random().nextDouble() * 5 + 0.5; // Smaller size range
    speed = Random().nextDouble() * 0.05 + 0.01; // Much slower speed
    color = baseColor
        .withOpacity(Random().nextDouble() * 0.4 + 0.1); // More transparent
    shape = ShapeType.values[Random().nextInt(ShapeType.values.length)];
  }
}

enum ShapeType { circle, square, triangle }

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y +=
          particle.speed * animation; // Use animation value to smooth movement
      if (particle.y > 1) {
        particle.reset(particle.color);
      }

      final paint = Paint()..color = particle.color;
      final position =
          Offset(particle.x * size.width, particle.y * size.height);

      switch (particle.shape) {
        case ShapeType.circle:
          canvas.drawCircle(position, particle.size, paint);
          break;
        case ShapeType.square:
          canvas.drawRect(
            Rect.fromCenter(
                center: position,
                width: particle.size * 2,
                height: particle.size * 2),
            paint,
          );
          break;
        case ShapeType.triangle:
          final path = Path()
            ..moveTo(position.dx, position.dy - particle.size)
            ..lineTo(position.dx - particle.size, position.dy + particle.size)
            ..lineTo(position.dx + particle.size, position.dy + particle.size)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
