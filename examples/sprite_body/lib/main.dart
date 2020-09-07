import 'package:box2d_flame/box2d.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame_box2d/box2d_game.dart';
import 'package:flame_box2d/sprite_body_component.dart';
import 'package:flutter/material.dart';

import 'boundaries.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class Ship extends SpriteBodyComponent {
  final Vector2 _position;

  Ship(this._position, Box2DGame game)
      : super(Sprite('ship.png'), 10, 15, game);

  @override
  Body createBody() {
    final PolygonShape shape = PolygonShape();

    final v1 = Vector2(0, height / 2);
    final v2 = Vector2(width / 2, -height / 2);
    final v3 = Vector2(-width / 2, -height / 2);
    final vertices = [v1, v2, v3];
    shape.set(vertices, vertices.length);

    final fixtureDef = FixtureDef();
    fixtureDef.setUserData(this); // To be able to determine object in collision
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.3;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.2;

    final bodyDef = BodyDef();
    bodyDef.position = viewport.getScreenToWorld(_position);
    bodyDef.angle = (_position.x + _position.y) / 2 * 3.14;
    bodyDef.type = BodyType.DYNAMIC;
    return world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }
}

class MyGame extends Box2DGame with TapDetector {
  MyGame() : super(scale: 4.0, gravity: Vector2(0, -10.0)) {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);
    final Vector2 position =
        Vector2(details.globalPosition.dx, details.globalPosition.dy);
    add(Ship(position, this));
  }
}
