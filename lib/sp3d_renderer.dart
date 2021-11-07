import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/sp3d_faceobj.dart';
import 'package:simple_3d_renderer/sp3d_light.dart';
import 'package:simple_3d_renderer/sp3d_world.dart';
import 'package:simple_3d_renderer/sp3d_camera.dart';
import 'package:simple_3d_renderer/sp3d_v2d.dart';

///
/// (en)A widget for rendering Sp3dWorld.
/// The clip of the world taken by the Sp3dCamera is displayed on the screen.
///
/// (ja)Sp3dWorldのレンダリング用ウィジェットです。
/// Sp3dCameraで撮影されたワールドのクリップをスクリーン上に表示します。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-07-18 15:41:26
///
class Sp3dRenderer extends StatefulWidget {
  final String className = 'Sp3dRenderer';
  final String version = '4';
  final GlobalKey key;
  final Size size;
  final Sp3dV2D worldOrigin;
  final Sp3dWorld world;
  final Sp3dCamera camera;
  final Sp3dLight light;
  final bool useUserGesture;

  /// Constructor
  /// * [key] : Global Key.
  /// * [size] : Canvas size for screen display.
  /// * [worldOrigin] : Sp3dWorld origin.
  /// This shows where the origin of the world is on the canvas.
  /// That is, specify somewhere in the canvas specified by the size parameter.
  /// * [world] : Objects to be drawn.
  /// * [camera] : camera.
  /// * [light] : light.
  /// * [useUserGesture] : If true, apply GestureDetector.
  Sp3dRenderer(this.key, this.size, this.worldOrigin, this.world, this.camera,
      this.light,
      {this.useUserGesture = true})
      : super(key: key);

  @override
  _Sp3dRendererState createState() => _Sp3dRendererState();

  /// (en)Deep copy the object.
  ///
  /// (ja)このオブジェクトをディープコピーします。
  ///
  /// * [key] : New GlobalKey.
  Sp3dRenderer deepCopy(GlobalKey key) {
    return Sp3dRenderer(key, this.size, this.worldOrigin.deepCopy(),
        this.world.deepCopy(), this.camera.deepCopy(), this.light.deepCopy(),
        useUserGesture: this.useUserGesture);
  }

  /// (en)Convert the object to a dictionary.
  ///
  /// (ja)このオブジェクトを辞書に変換します。
  ///
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = this.className;
    d['version'] = this.version;
    d['size'] = [this.size.width, this.size.height];
    d['world_origin'] = this.worldOrigin.toDict();
    d['world'] = this.world.toDict();
    d['camera'] = this.camera.toDict();
    d['lights'] = this.light.toDict();
    d['use_user_gesture'] = this.useUserGesture;
    return d;
  }

  /// (en)Restore this object from the dictionary.
  ///
  /// (ja)辞書からオブジェクトを復元します。
  ///
  /// * [key] : GlobalKey.
  /// * [src] : A dictionary made with to_dict of this class.
  static Sp3dRenderer fromDict(GlobalKey key, Map<String, dynamic> src) {
    List<Sp3dObj> objs = [];
    for (Map<String, dynamic> i in src['sp3d_objs']) {
      objs.add(Sp3dObj.fromDict(i));
    }
    return Sp3dRenderer(
        key,
        Size(src['size'][0], src['size'][1]),
        Sp3dV2D.fromDict(src['world_origin']),
        Sp3dWorld.fromDict(src['world']),
        Sp3dCamera.fromDict(src['camera']),
        Sp3dLight.fromDict(src['light']),
        useUserGesture: src['use_user_gesture']);
  }
}

class _Sp3dRendererState extends State<Sp3dRenderer> {
  // ドラッグ開始位置
  Sp3dV3D _sp = Sp3dV3D(0, 0, 0);

  // 前回のユーザードラッグ位置
  Sp3dV3D _preP = Sp3dV3D(0, 0, 0);

  // 現在の回転角
  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.useUserGesture) {
      return GestureDetector(
        child: CustomPaint(
          painter: _Sp3dCanvasPainter(widget),
          size: widget.size,
        ),
        // ドラッグ操作開始
        onPanStart: (DragStartDetails dsd) {
          this._sp = Sp3dV3D(dsd.localPosition.dx, dsd.localPosition.dy, 0);
          this._preP = Sp3dV3D(dsd.localPosition.dx, dsd.localPosition.dy, 0);
        },
        // ドラッグ操作中の変化
        onPanUpdate: (DragUpdateDetails dud) {
          setState(() {
            final Sp3dV3D nowP =
                Sp3dV3D(dud.localPosition.dx, dud.localPosition.dy, 0);
            final Sp3dV3D moveP = nowP - this._preP;
            this._angle += moveP.len();
            if (this._angle > 360) {
              this._angle %= 360;
            }
            final Sp3dV3D diff = nowP - this._sp;
            final Sp3dV3D axis = Sp3dV3D(diff.y, diff.x, 0).nor();
            widget.camera.rotate(axis, this._angle * pi / 180);
            _preP = nowP;
          });
        },
        // ドラッグ操作終了時
        onPanEnd: (DragEndDetails ded) {
          // 何もしない
        },
      );
    } else {
      return CustomPaint(
        painter: _Sp3dCanvasPainter(widget),
        size: widget.size,
      );
    }
  }
}

class _Sp3dCanvasPainter extends CustomPainter {
  final Sp3dRenderer w;
  final Paint p = Paint();
  final Path path = Path();

  _Sp3dCanvasPainter(this.w);

  @override
  void paint(Canvas canvas, Size size) {
    // カメラで撮影した２次元座標とカメラまでの距離などを含むデータオブジェクトを取得。
    // なお、描画対象外のオブジェクトはここで除外される。
    final List<Sp3dFaceObj> allFaces =
        this.w.camera.getPrams(this.w.world, this.w.worldOrigin);
    // z軸を基準にして遠いところから順番に塗りつぶすために全てのfaceを逆順ソート。
    allFaces.sort((Sp3dFaceObj a, Sp3dFaceObj b) => b.dist.compareTo(a.dist));
    // 描画
    for (Sp3dFaceObj fo in allFaces) {
      // パスを描画
      // 塗りつぶしの設定
      bool isFill = true;
      double strokeWidth = 0;
      Sp3dMaterial? material;
      if (fo.face.materialIndex != null) {
        material = fo.obj.materials[fo.face.materialIndex!];
        isFill = material.isFill;
        strokeWidth = material.strokeWidth;
      }
      final List<Color> colors =
          this.w.light.apply(fo.nsn, fo.camTheta, material);
      if (isFill) {
        if (material != null && material.imageIndex != null) {
          if (w.world.paintImages.containsKey(material)) {
            if (w.world.paintImages[material] != null) {
              canvas.drawVertices(
                  w.world.paintImages[material]!.updateVertices(fo),
                  BlendMode.srcOver,
                  w.world.paintImages[material]!.getPaint());
            }
          }
        } else {
          // 塗りつぶし
          p.color = colors[0];
          p.style = PaintingStyle.fill;
          bool isStartPoint = true;
          for (Sp3dV2D v in fo.vertices2d) {
            if (isStartPoint) {
              path.moveTo(v.x, v.y);
              isStartPoint = false;
            } else {
              path.lineTo(v.x, v.y);
            }
          }
          path.close();
          canvas.drawPath(path, p);
          path.reset();
        }
      }
      // 外枠の描画
      if (strokeWidth > 0) {
        p.color = colors[1];
        p.strokeWidth = strokeWidth;
        p.strokeCap = StrokeCap.butt;
        p.style = PaintingStyle.stroke;
        bool isStartPoint = true;
        for (Sp3dV2D v in fo.vertices2d) {
          if (isStartPoint) {
            path.moveTo(v.x, v.y);
            isStartPoint = false;
          } else {
            path.lineTo(v.x, v.y);
          }
        }
        path.close();
        canvas.drawPath(path, p);
        path.reset();
      }
    }
  }

  @override
  bool shouldRepaint(_Sp3dCanvasPainter p) {
    return true;
  }
}
