import 'dart:math' as math;

import 'package:forge2d/forge2d.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class MyPlanet extends BodyComponent {
  static final red = const PaletteEntry(Colors.red).paint;
  static final black = const PaletteEntry(Colors.black).paint;
  static final blue = const PaletteEntry(Colors.blue).paint;

  double totalTime = 0;
  // Creates a BodyComponent that renders a red circle (with a black moving
  // pulsating circle on the inside) that can interact with other body
  // components that are added to the same Forge2DGame/Forge2DComponent.
  // After 20 seconds the circle will be removed, to show that we don't get
  // any concurrent modification exceptions.
  MyPlanet(Forge2DGame game) : super(game);

  @override
  Body createBody() {
    final CircleShape shape = CircleShape();
    shape.radius = 50.0;

    final fixtureDef = FixtureDef();
    // To be able to determine object in collision
    fixtureDef.setUserData(this);
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.0;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;

    final bodyDef = BodyDef();
    bodyDef.position = Vector2.zero();
    bodyDef.angularVelocity = 4.0;
    bodyDef.type = BodyType.DYNAMIC;

    return world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }

  @override
  bool destroy() {
    // Implement your logic for when the component should be removed
    return totalTime > 20;
  }

  @override
  void renderCircle(Canvas c, Offset p, double radius) {
    c.drawCircle(p, radius, red);

    final angle = body.getAngle();
    c.drawCircle(p, math.sin(angle) * radius, black);

    final lineRotation =
        Offset(math.sin(angle) * radius, math.cos(angle) * radius);
    c.drawLine(p, p + lineRotation, blue);
  }

  @override
  void update(double t) {
    super.update(t);
    totalTime += t;
  }
}

class MyGame extends Forge2DGame {
  MyGame() : super(scale: 4.0, gravity: Vector2.zero()) {
    add(MyPlanet(this));
  }
}
