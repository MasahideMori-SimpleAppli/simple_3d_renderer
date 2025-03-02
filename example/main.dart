import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final List<Sp3dObj> _objs = [];
  late Sp3dWorld _world;
  bool _isLoaded = false;
  // Use the camera that best suits your needs.
  // This package allows you to customize various movements,
  // including camera rotation control, by extending the controller class.
  final Sp3dCamera _camera = Sp3dCamera(Sp3dV3D(0, 0, 1000), 1000);
  // final Sp3dFreeLookCamera _camera = Sp3dFreeLookCamera(Sp3dV3D(0,0,1000), 1000);
  final Sp3dCameraRotationController _camRCtrl = Sp3dCameraRotationController();
  static const Sp3dCameraZoomController _camZCtrl = Sp3dCameraZoomController();

  @override
  void initState() {
    super.initState();
    // Create Sp3dObj.
    Sp3dObj obj = UtilSp3dGeometry.cube(200, 200, 200, 4, 4, 4);
    obj.materials.add(FSp3dMaterial.green.deepCopy());
    obj.fragments[0].faces[0].materialIndex = 1;
    obj.materials[0] = FSp3dMaterial.grey.deepCopy()
      ..strokeColor = const Color.fromARGB(255, 0, 0, 255);
    obj.rotate(Sp3dV3D(1, 1, 0).nor(), 30 * 3.14 / 180);
    _objs.add(obj);
    loadImage();
  }

  void loadImage() async {
    _world = Sp3dWorld(_objs);
    _world.initImages().then((List<Sp3dObj> errorObjs) {
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return MaterialApp(
          title: 'Sp3dRenderer',
          home: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 0, 255, 0),
              ),
              backgroundColor: const Color.fromARGB(255, 33, 33, 33),
              body: Container()));
    } else {
      return MaterialApp(
        title: 'Sp3dRenderer',
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 255, 0),
          ),
          backgroundColor: const Color.fromARGB(255, 33, 33, 33),
          body: Column(
            children: [
              Sp3dRenderer(
                const Size(600, 600),
                const Sp3dV2D(300, 300),
                _world,
                // If you want to reduce distortion, shoot from a distance at high magnification.
                _camera,
                Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
                rotationController: _camRCtrl,
                zoomController: _camZCtrl,
              ),
            ],
          ),
        ),
      );
    }
  }
}
