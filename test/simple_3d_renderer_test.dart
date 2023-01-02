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
        Size(800, 800),
        Sp3dV2D.fromDict(Sp3dV2D(400, 400).toDict()),
        world,
        camera,
        li,
        rotationController: crCtrl,
      );
    });
  });
}
