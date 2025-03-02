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

  test('Sp3dQuaternion serialization test', () {
    Sp3dQuaternion q1 = Sp3dQuaternion(1, 2, 3, 4);
    final qDict = q1.toDict();
    Sp3dQuaternion q2 = Sp3dQuaternion.fromDict(qDict);
    expect(q1.w == q2.w, true);
    expect(q1.x == q2.x, true);
    expect(q1.y == q2.y, true);
    expect(q1.z == q2.z, true);
  });

  test('Sp3dCameraRotationController serialization test', () {
    Sp3dCameraRotationController t1 = Sp3dCameraRotationController(
        rotationSpeed: 2,
        sp: const Sp3dV2D(1, 1),
        axis: Sp3dV3D(2, 3, 4),
        diff: const Sp3dV2D(2, 2),
        lastDiff: const Sp3dV2D(2, 2),
        lookAtTarget: Sp3dV3D(0, 1, 0));
    final tDict = t1.toDict();
    Sp3dCameraRotationController t2 =
        Sp3dCameraRotationController.fromDict(tDict);
    expect(t1.rotationSpeed == t2.rotationSpeed, true);
    expect(t1.sp.equals(t2.sp, 0.001), true);
    expect(t1.axis.equals(t2.axis, 0.001), true);
    expect(t1.diff.equals(t2.diff, 0.001), true);
    expect(t1.lastDiff.equals(t2.lastDiff, 0.001), true);
    expect(t1.lookAtTarget.equals(t2.lookAtTarget, 0.001), true);
  });

  test('Sp3dFreeLookCamera serialization test', () {
    Sp3dFreeLookCamera c1 = Sp3dFreeLookCamera(Sp3dV3D(0, 0, 3000), 6000);
    final cDict = c1.toDict();
    Sp3dFreeLookCamera c2 = Sp3dFreeLookCamera.fromDict(cDict);
    // 引数にある変数
    expect(c1.position.equals(c2.position, 0.001), true);
    expect(c1.focusLength == c2.focusLength, true);
    expect(c1.forward.equals(c2.forward, 0.001), true);
    expect(c1.up.equals(c2.up, 0.001), true);
    expect(c1.rotateAxis.equals(c2.rotateAxis, 0.001), true);
    expect(c1.radian == c2.radian, true);
    expect(c1.isAllDrawn == c2.isAllDrawn, true);
    // 内部変数系
    expect(c1.right.equals(c2.right, 0.001), true);
    expect(c1.rotatedPosition.equals(c2.rotatedPosition, 0.001), true);
  });
}
