# simple_3d_renderer

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/simple_3d_renderer/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/simple_3d_renderer/blob/main/README_JA.md)にあります。

## Overview
This package is for rendering Sp3dObj.  
Sp3dObj is an implementation of the Simple 3D Format created for science.
It is created mainly for use by scientists.  
Please refer to the following for the packages to be used together.

[simple_3d](https://pub.dev/packages/simple_3d)  
[util_simple_3d](https://pub.dev/packages/util_simple_3d)  

## Usage
```dart
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
                const Sp3dV2D(400, 400),
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
```
![Cube Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Util_Sp3dGeometry/cube_sample1.png)

## Use Image File
For example, rewrite sample code as follows.(*Note that some unnecessary parameters remain for simplicity)

### sample_image.png
![sample_image.png](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/sample_image.png)

```dart
  // Chenge Cube of initState().
  Sp3dObj obj = UtilSp3dGeometry.cube(200,200,200,1,1,1);
  --------------------------------------------------------------------
  // Chenge function
  void loadImage() async {
    this.objs[0].fragments[0].faces[0].materialIndex=1;
    this.objs[0].fragments[0].faces[1].materialIndex=1;
    this.objs[0].fragments[0].faces[2].materialIndex=1;
    this.objs[0].fragments[0].faces[3].materialIndex=1;
    this.objs[0].materials[1].imageIndex = 0;
    // You can use images by creating an assets/images folder under your project, adding images, and adding the asset path to pubspec.yaml.
    // For Flutter Web, you also need to copy it to your web folder.
    this.objs[0].images.add(await _readFileBytes("./assets/images/sample_image.png"));
    this.world = Sp3dWorld(objs);
    this.world.initImages().then(
            (List<Sp3dObj> errorObjs){
          setState(() {
            this.isLoaded = true;
          });
        }
    );
  }

  // Add function
  Future<Uint8List> _readFileBytes(String filePath) async {
    ByteData bd = await rootBundle.load(filePath);
    return bd.buffer.asUint8List(bd.offsetInBytes,bd.lengthInBytes);
  }
```
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample1.png)

### Triangle mesh
If the drawing destination of the image is a triangular mesh, the image is automatically divided into triangles with the vertices at the upper left, lower left, and lower right, and displayed.  
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample2.png)

You can also use the Sp3dMaterial parameters to control the cutout position with respect to the triangular mesh.  
*Note that the size of the image of paste to cone is (width, height) = (128, 128).
Since textureCoordinates specifies the position where you want to cut out the image, it indicate the points on the image.
And this image is (0,0) in the upper left and (128,128) in the lower right.
For example, the following sample is cut out at the upper left, the middle of the lower side, and the upper right.  
In the case of a square mesh, it is necessary to specify two triangles, so six vertices are required.  
```dart
Sp3dObj obj = UtilSp3dGeometry.cone(100,200);
obj.materials[0].strokeColor = Color.fromARGB(255, 0, 255, 0);
obj.materials[0].textureCoordinates = [Offset(0,0),Offset(64,128),Offset(128,0)];
```
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample3_custom_crop.png)

## How to follow a user's touch event
For example, rewrite sample code as follows.  
The return value Sp3dFaceObj in onPanDown is a class that contains information about the touched surface.  
The sample uses this information to move the object touched by the user.  
```dart
  // Add variable to _MyAppState.
  ValueNotifier<int> vn = ValueNotifier<int>(0);
  --------------------------------------------------------------------
  // Rewrite Sp3dRenderer.
  Sp3dRenderer(
    const Size(800, 800),
    const Sp3dV2D(400, 400),
    world,
    // If you want to reduce distortion, shoot from a distance at high magnification.
    Sp3dCamera(Sp3dV3D(0, 0, 30000), 60000),
    Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
    allowUserWorldRotation: true,
    checkTouchObj: true,
    vn: vn,
    onPanDown: (Sp3dGestureDetails d, Sp3dFaceObj? info){
      print("onPanDown");
      if(info!=null) {
        info.obj.move(Sp3dV3D(50, 0, 0));
        vn.value++;
      }
    },
    onPanCancel: (){
      print("onPanCancel");
    },
    onPanStart: (Sp3dGestureDetails d){
      print("onPanStart");
      print(d.toOffset());
    },
    onPanUpdate: (Sp3dGestureDetails d){
      print("onPanUpdate");
      print(d.toOffset());
    },
    onPanEnd: (Sp3dGestureDetails d){
      print("onPanEnd");
    },
    onPinchStart: (Sp3dGestureDetails d){
      print("onPinchStart");
      print(d.diffV);
    },
    onPinchUpdate: (Sp3dGestureDetails d){
      print("onPinchUpdate");
      print(d.diffV);
    },
    onPinchEnd: (Sp3dGestureDetails d){
      print("onPinchEnd");
      print(d.diffV);
    },
    onMouseScroll: (Sp3dGestureDetails d){
      print("onMouseScroll");
      print(d.diffV);
    },
  )
```
## Save or Restore the Sp3dWorld
If you want to save / restore multiple Sp3dObj along with their location, Sp3dWorld also has toDict and fromDict methods.  
The extension when saving is recommended to be .s3dw to avoid confusion.  

## Support
If you need paid support for any reason, please contact my company.  
This package is developed by me personally, but may be supported via the company.  
[SimpleAppli Inc.](https://simpleappli.com/en/index_en.html)

## Rendering Speed (20 paint average)
This is a consideration of the time it takes to draw on a web browser 
in debug mode on a mid-range machine with a CPU of 3.40Ghz and 16GB memory.  
There are some speed issues, such as running on a CPU and being single-threaded.  
In the case of real-time rendering, the limit is about 1000 cubes (8000 vertices), and anything over that is heavy.  
For models such as spheres with many vertices, the amount you can comfortably manipulate is much less.  
Note: Not all objects will have similar performance due to the impact of speedup logic.  
```dart
/// use cube obj(8 vertices / 1 obj)
Sp3dObj obj = UtilSp3dGeometry.cube(5, 5, 5, 1, 1, 1);
```
- 100 cube 4.7 ms / paint. (800 vertices, 212.8 fps)
- 500 cube 23.8 ms / paint.
- 1000 cube 47.7 ms / paint. (8000 vertices, 21.0 fps)
```dart
/// use sphere obj(72 vertices / 1 obj)
Sp3dObj obj = UtilSp3dGeometry.sphere(2.5);
```
- 100 sphere 60.0 ms / paint. (7200 vertices, 16.6 fps)
- 500 sphere 307.6 ms / paint.
- 1000 sphere 619.4 ms / paint. (72000 vertices, 1.6 fps)

## About version control
The C part will be changed at the time of version upgrade.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
This software is released under the MIT License, see LICENSE file.  

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.