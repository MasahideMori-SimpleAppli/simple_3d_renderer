# simple_3d_renderer

日本語版の解説です。

## 概要
このパッケージはSp3dObjのレンダリングのためのパッケージです。  
Sp3dObjは科学のために作られた3Dフォーマット(Simple 3D Format)を実装したもので、
主に科学者などの利用を考えて作成されています。  
合わせて使うパッケージについては下記を参照してください。  

[simple_3d](https://pub.dev/packages/simple_3d)  
[util_simple_3d](https://pub.dev/packages/util_simple_3d)  

## 使い方
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
    Sp3dObj obj = UtilSp3dGeometry.cube(200,200,200,4,4,4);
    obj.materials.add(FSp3dMaterial.green.deepCopy());
    obj.fragments[0].faces[0].materialIndex=1;
    obj.materials[0] = FSp3dMaterial.grey.deepCopy()..strokeColor=Color.fromARGB(255, 0, 0, 255);
    obj.rotate(Sp3dV3D(1,1,0).nor(), 30*3.14/180);
    this.objs.add(obj);
    loadImage();
  }

  void loadImage() async {
    this.world = Sp3dWorld(objs);
    this.world.initImages().then(
        (List<Sp3dObj> errorObjs){
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
                  Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true)
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

## 画像ファイルを扱う場合の操作
例えば、サンプルコードを以下のように書き替えます。(※簡単のために、不要なパラメータも残っていることに注意してください)  

### sample_image.png
![sample_image.png](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/sample_image.png)

```dart
  // Cube の initState()内、オブジェクト生成部分を変更してください。
  Sp3dObj obj = UtilSp3dGeometry.cube(200,200,200,1,1,1);
  --------------------------------------------------------------------
  // 関数を書き換えます。
  void loadImage() async {
    this.objs[0].fragments[0].faces[0].materialIndex=1;
    this.objs[0].fragments[0].faces[1].materialIndex=1;
    this.objs[0].fragments[0].faces[2].materialIndex=1;
    this.objs[0].fragments[0].faces[3].materialIndex=1;
    this.objs[0].materials[1].imageIndex = 0;
    // プロジェクトの直下にassets/imagesフォルダを作って画像を追加し、pubspec.yamlにアセットのパスを追加することで、画像を使用できます。
    // Flutter Webの場合は、さらにそれをwebフォルダへコピーする必要があります。
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

  // 関数を追加します。
  Future<Uint8List> _readFileBytes(String filePath) async {
    ByteData bd = await rootBundle.load(filePath);
    return bd.buffer.asUint8List(bd.offsetInBytes,bd.lengthInBytes);
  }
```
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample1.png)

### 三角メッシュ
画像の描画先が三角メッシュの場合、画像は左上、左下、右下を頂点とする三角形に自動で分割されて表示されます。  
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample2.png)

Sp3dMaterialのパラメータを使用して、三角メッシュに対する切り出し位置をコントロールすることも出来ます。  
ここでは、張り付けたい画像のサイズが(width, height)=(128, 128)であることに注意してください。textureCoordinatesは画像の切り出したい位置を指定するため、３D空間では無く画像上の点を示します。
そして、この画像は左上が(0,0)、右下が(128,128)です。例えば以下のサンプルは左上、下側の中間、右上で切り出しています。  
なお、四角メッシュの場合は、三角形２つの指定が必要なため、頂点は6つ必要になります。  
```dart
Sp3dObj obj = UtilSp3dGeometry.cone(100,200);
obj.materials[0].strokeColor = Color.fromARGB(255, 0, 255, 0);
obj.materials[0].textureCoordinates = [Offset(0,0),Offset(64,128),Offset(128,0)];
```
![Texture Sample](https://raw.githubusercontent.com/MasahideMori1111/simple_3d_images/main/Sp3dRenderer/texture_sample3_custom_crop.png)

## タッチイベントの取得方法と、動的なオブジェクトの変更方法。
例えば、サンプルコードを以下のように書き換えます。  
onPanDownListenerの戻り値は、タッチされたサーフェスに関する情報を含むクラスです。  
このサンプルでは、この情報を使用して、ユーザーがタッチしたオブジェクトを移動しています。  
```dart
  // インポートを追加します.
  import 'package:simple_3d_renderer/sp3d_faceobj.dart';
  // _MyAppStateの変数を追加してください.
  ValueNotifier<int> vn = ValueNotifier<int>(0);
  --------------------------------------------------------------------
  // Sp3dRendererを書き換えます.
  Sp3dRenderer(
    k,
    Size(800, 800),
    Sp3dV2D(400, 400),
    this.world,
    // If you want to reduce distortion, shoot from a distance at high magnification.
    Sp3dCamera(Sp3dV3D(0, 0, 30000), 60000),
    Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
    allowFullCtrl: true,
    allowUserWorldRotation: true,
    checkTouchObj: true,
    vn: this.vn,
    onPanDownListener: (Offset offset, Sp3dFaceObj? info){
      print("onPanDown");
      if(info!=null) {
        info.obj.move(Sp3dV3D(50, 0, 0));
        this.vn.value++;
      }
    },
    onPanCancelListener: (){
      print("onPanCancel");
    },
    onPanStartListener: (Offset offset){
      print("onPanStart");
      print(offset);
    },
    onPanUpdateListener: (Offset offset){
      print("onPanUpdate");
      print(offset);
    },
    onPanEndListener: (){
      print("onPanEnd");
    },
  )
```

## Sp3dWorldの保存と復元
複数のSp3dObjをその位置と共に保存または復元したい場合、Sp3dWorldにもtoDict、及びfromDictメソッドがあります。  
保存時の拡張子は混乱を避けるために.s3dwを推奨します。

## サポート
もし何らかの理由で有償のサポートが必要な場合は私の会社に問い合わせてください。  
このパッケージは私が個人で開発していますが、会社経由でサポートできる場合があります。  
[合同会社シンプルアプリ](https://simpleappli.com/index.html)  

## レンダリングの速度 (10回の描画の平均値)
ver 0.0.3時点における、CPU 3.40Ghz, 16GB memoryのミッドレンジのマシン上で、debug modeかつWebブラウザ上での描画にかかる時間の考察です。  
CPUで動作すること、シングルスレッド処理であることなど、速度の上でいくつかの課題があります。  
リアルタイムレンダリングの場合、体感的には1000 cube (8000 vertices)ぐらいが限界で、2500 cube (20000 vertices)以上だと重いです。  
多くの頂点を持つ球などのモデルの場合、快適に操作出来る量はもっと少なくなります。  
注意：高速化ロジックの影響があるため、どんなオブジェクトでも同様なパフォーマンスになるわけではありません。  
```dart
/// use cube obj(8 vertices / 1 obj)
Sp3dObj obj = UtilSp3dGeometry.cube(5, 5, 5, 1, 1, 1);
```
- 100 cube 4 ms / paint. (800 vertices, 250.0 fps)
- 500 cube 19 ms / paint.
- 1000 cube 38 ms / paint. (8000 vertices, 26.3 fps)
- 2500 cube 95 ms / paint. (20000 vertices, 10.5 fps)
- 5000 cube 197 ms / paint.
```dart
/// use sphere obj(72 vertices / 1 obj)
Sp3dObj obj = UtilSp3dGeometry.sphere(2.5);
```
- 100 sphere 46 ms / paint. (7200 vertices, 21.7 fps)
- 500 sphere 236 ms / paint.
- 1000 sphere 473 ms / paint.
- 2500 sphere 1219 ms / paint.
- 5000 sphere 2532 ms / paint. (360000 vertices)

## バージョン管理について
それぞれ、Cの部分が変更されます。  
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
    - C.X.X
- メソッドの追加など
    - X.C.X
- 軽微な変更やバグ修正
    - X.X.C

## ライセンス
このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## 著作権表示
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.