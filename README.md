# simple_3d_renderer

(en)The explanation is in English and Japanese.  
(ja)日本語版は(ja)として記載してあります。

## Overview
(en)This package is for rendering Sp3dObj.  
Sp3dObj is an implementation of the Simple 3D Format created for science.
It is created mainly for use by scientists.  
Please refer to the following for the packages to be used together.  

(ja)このパッケージはSp3dObjのレンダリングのためのパッケージです。  
Sp3dObjは科学のために作られた3Dフォーマット(Simple 3D Format)を実装したもので、
主に科学者などの利用を考えて作成されています。  
合わせて使うパッケージについては下記を参照してください。  

[simple_3d](https://pub.dev/packages/simple_3d)  
[util_simple_3d](https://pub.dev/packages/util_simple_3d)  

## Usage
```dart
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_sp3d_geometry.dart';
import 'package:util_simple_3d/f_sp3d_material.dart';
import 'package:simple_3d_renderer/sp3d_renderer.dart';
import 'package:simple_3d_renderer/sp3d_v2d.dart';
import 'package:simple_3d_renderer/sp3d_world.dart';
import 'package:simple_3d_renderer/sp3d_camera.dart';
import 'package:simple_3d_renderer/sp3d_light.dart';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final k = GlobalKey();
  late List<Sp3dObj> objs = [];
  late Sp3dWorld world;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Create Sp3dObj.
    Sp3dObj obj = Util_Sp3dGeometry.cube(200,200,200,4,4,4);
    obj.materials.add(F_Sp3dMaterial.green.deep_copy());
    obj.fragments[0].faces[0].material_index=1;
    obj.materials[0] = F_Sp3dMaterial.grey..stroke_color=Color.fromARGB(255, 0, 0, 255);
    obj.rotate(Sp3dV3D(1,1,0).nor(), 30*3.14/180);
    this.objs.add(obj);
    loadImage();
  }

  void loadImage() async {
    this.world = Sp3dWorld(objs);
    this.world.init_images().then(
        (List<Sp3dObj> error_objs){
          setState(() {
            this.isLoaded = true;
          });
        }
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!this.isLoaded) {
      return MaterialApp(
          title: 'Sp3dRenderer',
          home: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 0, 255, 0),
              ),
              backgroundColor: Color.fromARGB(255, 33, 33, 33),
              body: Container()
          )
      );
    }
    else {
      return MaterialApp(
        title: 'Sp3dRenderer',
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 0, 255, 0),
          ),
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
          body: Column(
            children: [
              Sp3dRenderer(
                  k,
                  Size(800, 800),
                  Sp3dV2D(400, 400),
                  this.world,
                  // If you want to reduce distortion, shoot from a distance at high magnification.
                  Sp3dCamera(Sp3dV3D(0, 0, 30000), 60000),
                  Sp3dLight(Sp3dV3D(0, 0, -1), sync_cam: true)
              )
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
(en)For example, rewrite sample code as follows.(*Note that some unnecessary parameters remain for simplicity)  
(ja)例えば、サンプルコードを以下のように書き替えます。(※簡単のために、不要なパラメータも残っていることに注意してください)  

### sample_image.png
![sample_image.png](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/sample_image.png)

```dart
  // Chenge Cube of initState().
  Sp3dObj obj = Util_Sp3dGeometry.cube(200,200,200,1,1,1);
  --------------------------------------------------------------------
  // Chenge function
  void loadImage() async {
    this.objs[0].fragments[0].faces[0].material_index=1;
    this.objs[0].fragments[0].faces[1].material_index=1;
    this.objs[0].fragments[0].faces[2].material_index=1;
    this.objs[0].fragments[0].faces[3].material_index=1;
    this.objs[0].materials[1].image_index = 0;
    // You can also use the image by adding the image directly under the project like this and listing the asset in pubspec.yaml.
    this.objs[0].images.add(await _readFileBytes("./assets/images/sample_image.png"));
    this.world = Sp3dWorld(objs);
    this.world.init_images().then(
            (List<Sp3dObj> error_objs){
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
(en)If the drawing destination of the image is a triangular mesh, the image is automatically divided into triangles with the vertices at the upper left, lower left, and lower right, and displayed.  
(ja)画像の描画先が三角メッシュの場合、画像は左上、左下、右下を頂点とする三角形に自動で分割されて表示されます。  
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample2.png)

(en)You can also use the Sp3dMaterial parameters to control the cutout position with respect to the triangular mesh.  
*Note that the size of the image of paste to cone is (width, height) = (128, 128). Since texture_coordinates specifies the position where you want to cut out the image, it indicate the points on the image. And this image is (0,0) in the upper left and (128,128) in the lower right.  
(ja)Sp3dMaterialのパラメータを使用して、三角メッシュに対する切り出し位置をコントロールすることも出来ます。  
ここでは、張り付けたい画像のサイズが(width, height)=(128, 128)であることに注意してください。texture_coordinatesは画像の切り出したい位置を指定するため、３D空間では無く画像上の点を示します。そして、この画像は左上が(0,0)、右下が(128,128)です。
```dart
Sp3dObj obj = Util_Sp3dGeometry.cone(100,200);
obj.materials[0].stroke_color=Color.fromARGB(255, 0, 255, 0);
obj.materials[0].texture_coordinates = [Offset(0,0),Offset(64,128),Offset(128,0)];
```
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample3_custom_crop.png)


## Support
(en)If you need paid support, please contact my company.  
[SimpleAppli Inc.](https://simpleappli.com/en/index_en.html)  
(ja)もし何らかの理由で有償のサポートが必要な場合は私の会社に問い合わせてください。  
このパッケージは私が個人で開発していますが、会社経由でサポートできる場合があります。  
[合同会社シンプルアプリ](https://simpleappli.com/index.html)  

## Rendering Speed (10 paint average)
(en)It is a consideration of the time required for drawing on a web browser 
in debug mode on a midrange machine with CPU 3.40Ghz and 16GB memory as of Sp3dRenderer ver 0.0.3.  
There are some speed issues (CPU Run, Single thread).  
In the case of real-time rendering, the limit is about 1000 cubes (8000 vertices), and 2500 cubes (20000 vertices) or more is heavy.  
For models such as spheres with many vertices, the amount that can be operated comfortably is much smaller.  
Note: Not all objects will have similar performance due to the impact of speedup logic.  

(ja)ver 0.0.3時点における、CPU 3.40Ghz, 16GB memoryのミッドレンジのマシン上で、debug modeかつWebブラウザ上での描画にかかる時間の考察です。  
CPUで動作すること、シングルスレッド処理であることなど、速度の上でいくつかの課題があります。  
リアルタイムレンダリングの場合、体感的には1000 cube (8000 vertices)ぐらいが限界で、2500 cube (20000 vertices)以上だと重いです。  
多くの頂点を持つ球などのモデルの場合、快適に操作出来る量はもっと少なくなります。  
注意：高速化ロジックの影響があるため、どんなオブジェクトでも同様なパフォーマンスになるわけではありません。  
```dart
/// use cube obj(8 vertices / 1 obj)
Sp3dObj obj = Util_Sp3dGeometry.cube(5, 5, 5, 1, 1, 1);
```
- 100 cube 4 ms / paint. (800 vertices, 250.0 fps)
- 500 cube 19 ms / paint.
- 1000 cube 38 ms / paint. (8000 vertices, 26.3 fps)
- 2500 cube 95 ms / paint. (20000 vertices, 10.5 fps)
- 5000 cube 197 ms / paint.
```dart
/// use sphere obj(72 vertices / 1 obj)
Sp3dObj obj = Util_Sp3dGeometry.sphere(2.5);
```
- 100 sphere 46 ms / paint. (7200 vertices, 21.7 fps)
- 500 sphere 236 ms / paint.
- 1000 sphere 473 ms / paint.
- 2500 sphere 1219 ms / paint.
- 5000 sphere 2532 ms / paint. (360000 vertices)

## About version control
(en)The C part will be changed at the time of version upgrade.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

(ja)それぞれ、Cの部分が変更されます。  
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
    - C.X.X
- メソッドの追加など
    - X.C.X
- 軽微な変更やバグ修正
    - X.X.C

## License
(en)This software is released under the MIT License, see LICENSE file.  
(ja)このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.