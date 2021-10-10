# simple_3d

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
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_sp3d_geometry.dart';
import 'package:util_simple_3d/f_sp3d_material.dart';
import 'package:simple_3d_renderer/sp3d_renderer.dart';
import 'package:simple_3d_renderer/sp3d_v2d.dart';
import 'package:simple_3d_renderer/sp3d_world.dart';
import 'package:simple_3d_renderer/sp3d_camera.dart';
import 'package:simple_3d_renderer/sp3d_light.dart';

class _MyAppState extends State<MyApp> {
  final k = GlobalKey();
  late Sp3dObj obj;

  @override
  void initState() {
    super.initState();
    // Create Sp3dObj.
    obj = Util_Sp3dGeometry.cube(200,200,200,4,4,4);
    obj.materials.add(F_Sp3dMaterial.green);
    obj.fragments[0].faces[0].material_index=1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sp3dRenderer',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
        ),
        backgroundColor: Color.fromARGB(255, 33, 33, 33),
        body: Column(
          children: [
            Sp3dRenderer(
                k,
                Size(800,800),
                Sp3dV2D(400,400),
                Sp3dWorld([obj]),
                // If you want to reduce distortion, shoot from a distance at high magnification. 
                Sp3dCamera(Sp3dV3D(0,0,30000), 60000),
                Sp3dLight(Sp3dV3D(0,0,-1),sync_cam: true)
            )
          ],
        ),
      ),
    );
  }
}
```

## About future development
(en)Currently, it does not support drawing of image files. I plan to implement it in the future.  
(ja)現在、画像ファイルの描画に対応していません。今後実装する予定です。

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