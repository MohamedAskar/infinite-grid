import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Custom physics implementation for momentum-based scrolling in the infinite grid.
class GridPhysics {
  /// Creates a new grid physics instance.
  const GridPhysics({
    this.friction = 0.015,
    this.minVelocity = 50.0,
    this.maxVelocity = 3000.0,
    this.decelerationRate = 0.85,
  });

  /// The friction coefficient for scrolling.
  final double friction;

  /// The minimum velocity before scrolling stops.
  final double minVelocity;

  /// The maximum velocity allowed for scrolling.
  final double maxVelocity;

  /// The deceleration rate for momentum scrolling.
  final double decelerationRate;

  /// Calculates the momentum scrolling animation for the given velocity.
  MomentumScrollSimulation createMomentumScrollSimulation({
    required Offset initialVelocity,
    required Offset initialPosition,
  }) {
    return MomentumScrollSimulation(
      initialVelocity: initialVelocity,
      initialPosition: initialPosition,
      friction: friction,
      minVelocity: minVelocity,
      maxVelocity: maxVelocity,
      decelerationRate: decelerationRate,
    );
  }

  /// Applies bounds to the velocity to ensure it's within acceptable limits.
  Offset clampVelocity(Offset velocity) {
    final magnitude = velocity.distance;
    if (magnitude > maxVelocity) {
      return Offset(
        velocity.dx / magnitude * maxVelocity,
        velocity.dy / magnitude * maxVelocity,
      );
    }
    return velocity;
  }

  /// Determines if the velocity is significant enough to continue scrolling.
  bool isVelocitySignificant(Offset velocity) {
    return velocity.distance >
        minVelocity * 2; // Higher threshold for starting momentum
  }
}

/// Simulation for momentum-based scrolling with physics.
class MomentumScrollSimulation {
  /// Creates a new momentum scroll simulation.
  MomentumScrollSimulation({
    required this.initialVelocity,
    required this.initialPosition,
    required this.friction,
    required this.minVelocity,
    required this.maxVelocity,
    required this.decelerationRate,
  }) : _startTime = 0;

  /// The initial velocity of the scroll.
  final Offset initialVelocity;

  /// The initial position of the scroll.
  final Offset initialPosition;

  /// The friction coefficient.
  final double friction;

  /// The minimum velocity before stopping.
  final double minVelocity;

  /// The maximum velocity allowed.
  final double maxVelocity;

  /// The deceleration rate.
  final double decelerationRate;

  final double _startTime;

  /// Calculates the position at the given time.
  Offset positionAt(double time) {
    final t = time - _startTime;
    final decayFactor = math.pow(decelerationRate, t);

    final deltaX =
        initialVelocity.dx * (1 - decayFactor) / (1 - decelerationRate);
    final deltaY =
        initialVelocity.dy * (1 - decayFactor) / (1 - decelerationRate);

    return Offset(initialPosition.dx + deltaX, initialPosition.dy + deltaY);
  }

  /// Calculates the velocity at the given time.
  Offset velocityAt(double time) {
    final t = time - _startTime;
    final decayFactor = math.pow(decelerationRate, t);

    return Offset(
      initialVelocity.dx * decayFactor,
      initialVelocity.dy * decayFactor,
    );
  }

  /// Determines if the simulation is done (velocity is too low).
  bool isDone(double time) {
    final velocity = velocityAt(time);
    return velocity.distance <= minVelocity;
  }

  /// Determines if the simulation should stop immediately due to very low velocity.
  bool shouldStopImmediately(double time) {
    final velocity = velocityAt(time);
    return velocity.distance <=
        minVelocity * 0.5; // Stop immediately at half the min velocity
  }

  /// Calculates the final position where the simulation will stop.
  Offset getFinalPosition() {
    final deltaX = initialVelocity.dx / (1 - decelerationRate);
    final deltaY = initialVelocity.dy / (1 - decelerationRate);

    return Offset(initialPosition.dx + deltaX, initialPosition.dy + deltaY);
  }

  /// Estimates the time when the simulation will be done.
  double getEstimatedDuration() {
    final initialSpeed = initialVelocity.distance;
    if (initialSpeed <= minVelocity) return 0.0;

    // Calculate time to reach minimum velocity
    return math.log(minVelocity / initialSpeed) / math.log(decelerationRate);
  }
}

/// Utility class for velocity estimation from touch events.
class VelocityTracker {
  /// Creates a new velocity tracker.
  VelocityTracker() : _samples = <_VelocitySample>[];

  final List<_VelocitySample> _samples;
  static const int _maxSamples = 10;
  static const Duration _sampleWindow = Duration(milliseconds: 50);

  /// Adds a position sample at the given time.
  void addSample(Offset position, Duration timestamp) {
    _samples.add(_VelocitySample(position, timestamp));

    // Remove old samples
    final cutoff = timestamp - _sampleWindow;
    _samples.removeWhere((sample) => sample.timestamp < cutoff);

    // Limit number of samples
    if (_samples.length > _maxSamples) {
      _samples.removeAt(0);
    }
  }

  /// Gets the current velocity estimate.
  Offset getVelocity() {
    if (_samples.length < 2) return Offset.zero;

    final latest = _samples.last;
    final earliest = _samples.first;

    final timeDelta = latest.timestamp - earliest.timestamp;
    if (timeDelta.inMicroseconds == 0) return Offset.zero;

    final positionDelta = latest.position - earliest.position;
    final timeInSeconds = timeDelta.inMicroseconds / 1000000.0;

    final velocity = Offset(
      positionDelta.dx / timeInSeconds,
      positionDelta.dy / timeInSeconds,
    );

    // Filter out very small velocities that might cause drift
    if (velocity.distance < 10.0) {
      return Offset.zero;
    }

    return velocity;
  }

  /// Clears all samples.
  void clear() {
    _samples.clear();
  }
}

/// Internal class for velocity samples.
class _VelocitySample {
  const _VelocitySample(this.position, this.timestamp);

  final Offset position;
  final Duration timestamp;
}
