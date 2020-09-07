import 'dart:ui';

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'package:flame/game/base_game.dart';

// TODO: alias can be removed once viewport is removed from flame
import 'viewport.dart' as box2d;
import 'body_component.dart';
import 'contact_callbacks.dart';

class Box2DGame extends BaseGame {
  static final Vector2 defaultGravity = Vector2(0.0, -10.0);
  static const int defaultWorldPoolSize = 100;
  static const int defaultWorldPoolContainerSize = 10;
  static const int defaultVelocityIterations = 10;
  static const int defaultPositionIterations = 10;
  static const double defaultScale = 1.0;

  World world;
  box2d.Viewport viewport;
  final int velocityIterations = defaultVelocityIterations;
  final int positionIterations = defaultPositionIterations;

  final ContactCallbacks _contactCallbacks = ContactCallbacks();

  Box2DGame({
    dimensions,
    Vector2 gravity,
    double scale = defaultScale,
  }) {
    dimensions ??= window.physicalSize;
    gravity ??= defaultGravity;
    final pool =
        DefaultWorldPool(defaultWorldPoolSize, defaultWorldPoolContainerSize);
    world = World.withPool(gravity, pool);
    world.setContactListener(_contactCallbacks);
    viewport = box2d.Viewport(dimensions, scale);
  }

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt, velocityIterations, positionIterations);
  }

  @override
  void resize(Size size) {
    super.resize(size);
    viewport.resize(size);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);

    switch (state) {
      case AppLifecycleState.resumed:
        resumeEngine();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        pauseEngine();
        break;
    }
  }

  void remove(BodyComponent component) {
    world.destroyBody(component.body);
    component.remove();
  }

  void initializeWorld() {}

  void addContactCallback(ContactCallback callback) {
    _contactCallbacks.register(callback);
  }

  void removeContactCallback(ContactCallback callback) {
    _contactCallbacks.deregister(callback);
  }

  void clearContactCallbacks() {
    _contactCallbacks.clear();
  }

  void cameraFollow(
    BodyComponent component, {
    double horizontal,
    double vertical,
  }) {
    viewport.cameraFollow(
      component,
      horizontal: horizontal,
      vertical: vertical,
    );
  }
}