import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

void main() {
  test('creation test', () {
    Sp3dWorld world =
        Sp3dWorld([UtilSp3dGeometry.cube(200, 200, 200, 4, 4, 4)]);
    Sp3dCamera camera = Sp3dCamera(Sp3dV3D(0, 0, 30000), 60000);
    camera = Sp3dCamera.fromDict(camera.toDict());
    camera = Sp3dOrthographicCamera(Sp3dV3D(0, 0, 30000), 60000);
    camera = Sp3dOrthographicCamera.fromDict(camera.toDict());
    Sp3dLight li = Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true);
    li = Sp3dLight.fromDict(li.toDict());
    Sp3dCameraRotationController crCtrl = Sp3dCameraRotationController();
    crCtrl = Sp3dCameraRotationController.fromDict(crCtrl.toDict());
    world = Sp3dWorld.fromDict(world.toDict());
    world.initImages().then((List<Sp3dObj> errorObjs) {
      Sp3dRenderer(
        const Size(800, 800),
        Sp3dV2D.fromDict(const Sp3dV2D(400, 400).toDict()),
        world,
        camera,
        li,
        rotationController: crCtrl,
      );
    });
  });

  test('Sp3dV2D rotated', () {
    Sp3dV2D origin = const Sp3dV2D(1, 0);
    Sp3dV2D p = const Sp3dV2D(2, 0);
    expect(
        p
            .rotated(origin, 90 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(1, 1), 0.01),
        true);
    expect(
        p
            .rotated(origin, -90 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(1, -1), 0.01),
        true);
    expect(
        p
            .rotated(origin, 180 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(0, 0), 0.01),
        true);
    expect(
        p
            .rotated(origin, -180 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(0, 0), 0.01),
        true);
    p = const Sp3dV2D(1, 1);
    expect(
        p
            .rotated(origin, 90 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(0, 0), 0.01),
        true);
    expect(
        p
            .rotated(origin, -90 * Sp3dConstantValues.toRadian)
            .equals(const Sp3dV2D(2, 0), 0.01),
        true);
  });

  test('Sp3dV2D direction', () {
    Sp3dV2D p1 = const Sp3dV2D(1, 0);
    Sp3dV2D p2 = const Sp3dV2D(1, 1);
    Offset p1o = const Offset(1, 0);
    Offset p2o = const Offset(1, 1);
    expect(p1.direction() == p1o.direction, true);
    expect(p2.direction() == p2o.direction, true);
  });

  test('Sp3dV2D angleTo', () {
    Sp3dV2D p1 = const Sp3dV2D(1, 0);
    Sp3dV2D p2 = const Sp3dV2D(1, 1);
    Sp3dV2D p3 = const Sp3dV2D(0, 1);
    expect(p1.angleTo(p2) * 180 / pi == 45, true);
    expect(p1.angleTo(p3) * 180 / pi == 90, true);
  });

  test('Sp3dV2D distTo', () {
    Sp3dV2D origin = const Sp3dV2D(0, 0);
    Sp3dV2D p1 = const Sp3dV2D(1, 0);
    Sp3dV2D p2 = const Sp3dV2D(0, 5);
    expect(origin.distTo(p1) == 1, true);
    expect(origin.distTo(p2) == 5, true);
  });

  test('Sp3dV2D angleFromLine', () {
    const double eRange = 0.001;
    Sp3dV2D p1 = const Sp3dV2D(0, 0);
    Sp3dV2D p2 = const Sp3dV2D(1, 1);
    Sp3dV2D p3 = const Sp3dV2D(0, 1);
    Sp3dV2D p4 = const Sp3dV2D(-1, 1);
    Sp3dV2D p5 = const Sp3dV2D(-1, 0);
    Sp3dV2D p6 = const Sp3dV2D(-1, -1);
    Sp3dV2D p7 = const Sp3dV2D(0, -1);
    Sp3dV2D p8 = const Sp3dV2D(1, -1);
    expect(
        Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p1), 0, eRange), true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p2), 45, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p3), 90, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p4), 135, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p5), 180, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p6), 225, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p7), 270, eRange),
        true);
    expect(Sp3dV2D.errorTolerance(Sp3dV2D.angleFromLine(p1, p8), 315, eRange),
        true);
  });
}
