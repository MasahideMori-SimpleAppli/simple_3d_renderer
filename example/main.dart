import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Sp3dObj> objs = [];
  late Sp3dWorld world;
  bool isLoaded = false;

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
    objs.add(obj);
    loadImage();
  }

  void loadImage() async {
    world = Sp3dWorld(objs);
    world.initImages().then((List<Sp3dObj> errorObjs) {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
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
                const Size(800, 800),
                Sp3dV2D(400, 400),
                world,
                // If you want to reduce distortion, shoot from a distance at high magnification.
                Sp3dCamera(Sp3dV3D(0, 0, 3000), 6000),
                Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
              ),
            ],
          ),
        ),
      );
    }
  }
}
