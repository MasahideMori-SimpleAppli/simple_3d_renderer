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
  final String class_name = 'Sp3dRenderer';
  final String version = '1';
  final GlobalKey key;
  final Size size;
  final Sp3dV2D world_origin;
  final Sp3dWorld world;
  final Sp3dCamera camera;
  final Sp3dLight light;
  final bool use_user_gesture;

  /// Constructor
  /// * [key] : Global Key.
  /// * [size] : Canvas size for screen display.
  /// * [world_origin] : Sp3dWorld origin.
  /// This shows where the origin of the world is on the canvas.
  /// That is, specify somewhere in the canvas specified by the size parameter.
  /// * [world] : Objects to be drawn.
  /// * [camera] : camera.
  /// * [light] : light.
  /// * [use_user_gesture] : If true, apply GestureDetector.
  Sp3dRenderer(this.key, this.size, this.world_origin, this.world, this.camera,
      this.light,
      {this.use_user_gesture = true})
      : super(key: key);

  @override
  _Sp3dRendererState createState() => _Sp3dRendererState();

  /// (en)Deep copy the object.
  ///
  /// (ja)このオブジェクトをディープコピーします。
  ///
  /// * [key] : New GlobalKey.
  Sp3dRenderer deep_copy(GlobalKey key) {
    return Sp3dRenderer(key, this.size, this.world_origin.deep_copy(),
        this.world.deep_copy(), this.camera.deep_copy(), this.light.deep_copy(),
        use_user_gesture: this.use_user_gesture);
  }

  /// (en)Convert the object to a dictionary.
  ///
  /// (ja)このオブジェクトを辞書に変換します。
  ///
  Map<String, dynamic> to_dict() {
    Map<String, dynamic> d = {};
    d['class_name'] = this.class_name;
    d['version'] = this.version;
    d['size'] = [this.size.width, this.size.height];
    d['world_origin'] = this.world_origin.to_dict();
    d['world'] = this.world.to_dict();
    d['camera'] = this.camera.to_dict();
    d['lights'] = this.light.to_dict();
    d['use_user_gesture'] = this.use_user_gesture;
    return d;
  }

  /// (en)Restore this object from the dictionary.
  ///
  /// (ja)辞書からオブジェクトを復元します。
  ///
  /// * [key] : GlobalKey.
  /// * [src] : A dictionary made with to_dict of this class.
  static Sp3dRenderer from_dict(GlobalKey key, Map<String, dynamic> src) {
    List<Sp3dObj> objs = [];
    for (Map<String, dynamic> i in src['sp3d_objs']) {
      objs.add(Sp3dObj.from_dict(i));
    }
    return Sp3dRenderer(
        key,
        Size(src['size'][0], src['size'][1]),
        Sp3dV2D.from_dict(src['world_origin']),
        Sp3dWorld.from_dict(src['world']),
        Sp3dCamera.from_dict(src['camera']),
        Sp3dLight.from_dict(src['light']),
        use_user_gesture: src['use_user_gesture']);
  }
}

class _Sp3dRendererState extends State<Sp3dRenderer> {
  // ドラッグ開始位置
  Sp3dV3D _sp = Sp3dV3D(0, 0, 0);
  // 前回のユーザードラッグ位置
  Sp3dV3D _pre_p = Sp3dV3D(0, 0, 0);
  // 現在の回転角
  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.use_user_gesture) {
      return GestureDetector(
        child: CustomPaint(
          painter: _Sp3dCanvasPainter(widget),
          size: widget.size,
        ),
        // ドラッグ操作開始
        onPanStart: (DragStartDetails dsd) {
          this._sp = Sp3dV3D(dsd.localPosition.dx, dsd.localPosition.dy, 0);
          this._pre_p = Sp3dV3D(dsd.localPosition.dx, dsd.localPosition.dy, 0);
        },
        // ドラッグ操作中の変化
        onPanUpdate: (DragUpdateDetails dud) {
          setState(() {
            final Sp3dV3D now_p =
            Sp3dV3D(dud.localPosition.dx, dud.localPosition.dy, 0);
            final Sp3dV3D move_p = now_p - this._pre_p;
            this._angle += move_p.len();
            if(this._angle > 360){
              this._angle %= 360;
            }
            final Sp3dV3D diff = now_p - this._sp;
            final Sp3dV3D axis = Sp3dV3D(diff.y, diff.x, 0).nor();
            widget.camera.rotate(axis, this._angle*pi/180);
            _pre_p = now_p;
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

  _Sp3dCanvasPainter(this.w);

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    // カメラで撮影した２次元座標とカメラまでの距離を取得
    for (Sp3dObj obj in this.w.world.objs) {
      List<Sp3dV2D> conv2d = this.w.camera.convert(obj, this.w.world_origin);
      List<Sp3dFaceObj> face_dist = this.w.camera.get_prams(obj, conv2d);
      // z軸を基準にして遠いところから順番に塗りつぶすために全てのfaceを逆順ソート。
      face_dist
          .sort((Sp3dFaceObj a, Sp3dFaceObj b) => b.dist.compareTo(a.dist));
      // 描画
      for (Sp3dFaceObj fo in face_dist) {
        // 0未満が出現したら残りは描画対象外
        if (fo.dist < 0) {
          break;
        }
        // パスを描画
        // 塗りつぶしの設定
        bool isFill = true;
        double stroke_width = 0;
        Sp3dMaterial? material;
        if (fo.face.material_index != null) {
          material = obj.materials[fo.face.material_index!];
          isFill = material.is_fill;
          stroke_width = material.stroke_width;
        }
        Paint paint = Paint();
        List<Color> colors = this.w.light.apply(fo.nsn, fo.cam_theta, material);
        if (isFill) {
          if (material != null && material.image_index != null) {
            // TODO 現在非対応
          } else {
            // 塗りつぶし
            paint.color = colors[0];
            paint.style = PaintingStyle.fill;
            Path path = Path();
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
            canvas.drawPath(path, paint);
          }
        }
        // 外枠の描画
        paint.color = colors[1];
        paint.strokeWidth = stroke_width;
        paint.strokeCap = StrokeCap.butt;
        paint.style = PaintingStyle.stroke;
        Path path = Path();
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
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Sp3dCanvasPainter p) {
    return true;
  }
}
