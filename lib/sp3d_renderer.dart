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
  final String version = '5';
  final GlobalKey key;
  final Size size;
  final Sp3dV2D worldOrigin;
  final Sp3dWorld world;
  final Sp3dCamera camera;
  final Sp3dLight light;
  final bool useUserGesture;
  final bool allowFullCtrl;
  final bool allowUserWorldRotation;
  final bool checkTouchObj;
  final ValueNotifier<int>? vn;

  // タッチリスナの定義。速度の問題があるので、onPanDownでのみ当たり判定の演算を行い、当たり判定があれば情報クラスを返す。
  final Function(Offset, Sp3dFaceObj?)? onPanDownListener;
  final Function()? onPanCancelListener;
  final Function(Offset)? onPanStartListener;
  final Function(Offset)? onPanUpdateListener;
  final Function()? onPanEndListener;

  /// Constructor
  /// * [key] : Global Key.
  /// * [size] : Canvas size for screen display.
  /// * [worldOrigin] : Sp3dWorld origin.
  /// This shows where the origin of the world is on the canvas.
  /// That is, specify somewhere in the canvas specified by the size parameter.
  /// * [world] : Objects to be drawn.
  /// * [camera] : camera.
  /// * [light] : light.
  /// * [useUserGesture] : If true, apply GestureDetector. If false, also disabled allowFullCtrl flag.
  /// * [allowFullCtrl] : If true, apply full listener. If false, apply world rotation by user.
  /// * [allowUserWorldRotation] : If true, allow world rotation by user when allowFullCtrl is true.
  /// However, when checkTouchObj is true and touch target is exist when onPanDown, the subsequent rotation is suppressed.
  /// * [checkTouchObj] : If this is true and allowFullCtrl is true, Returns the information of the object touched when onPanDown.
  /// If false, and if there is no touch target, null is returned by onPanDown.
  /// * [onPanDownListener] : Callback at user touch initiation. The arguments of the function to be set are the offset and the object touched at the time of touch.
  /// * [onPanCancelListener] : Callback at user touch cancel. It is called instead of onTouchEnd when user touch cancel.
  /// * [onPanStartListener] : Callback at user pan start.
  /// * [onPanUpdateListener] : Callback at user pan update.
  /// * [onPanEndListener] : Callback at user pan end.
  /// * [vn] : ValueNotifier. If update this notifier.value, custom painter in renderer will repaint.
  Sp3dRenderer(this.key, this.size, this.worldOrigin, this.world, this.camera,
      this.light,
      {this.useUserGesture = true,
      this.allowFullCtrl = false,
      this.allowUserWorldRotation = true,
      this.checkTouchObj = true,
      this.onPanDownListener,
      this.onPanCancelListener,
      this.onPanStartListener,
      this.onPanUpdateListener,
      this.onPanEndListener,
      this.vn})
      : super(key: key);

  @override
  _Sp3dRendererState createState() => _Sp3dRendererState();
}

class _Sp3dRendererState extends State<Sp3dRenderer> {
  // ドラッグ開始位置
  Sp3dV3D _sp = Sp3dV3D(0, 0, 0);

  // 前回のユーザードラッグ位置
  Sp3dV3D _preP = Sp3dV3D(0, 0, 0);

  // 現在の回転角
  double _angle = 0.0;

  // 当たり判定計算用のPath
  final Path _p = Path();

  // 以降の回転を抑制するかどうかのフラグ
  bool _canRotation = true;

  @override
  Widget build(BuildContext context) {
    if (widget.useUserGesture) {
      if (widget.allowFullCtrl) {
        return GestureDetector(
          child: CustomPaint(
            painter: _Sp3dCanvasPainter(widget),
            size: widget.size,
          ),
          onPanDown: (DragDownDetails d) {
            this._canRotation = true;
            if (widget.onPanDownListener != null) {
              if (widget.checkTouchObj) {
                for (Sp3dFaceObj i in widget.world.sortedAllFaces.reversed) {
                  this._p.reset();
                  if (i.vertices2d.length == 3) {
                    this._p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
                    this._p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
                    this._p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
                    this._p.close();
                    if (this._p.contains(d.localPosition)) {
                      widget.onPanDownListener!(d.localPosition, i);
                      this._canRotation = false;
                      return;
                    }
                  } else {
                    this._p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
                    this._p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
                    this._p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
                    this._p.lineTo(i.vertices2d[3].x, i.vertices2d[3].y);
                    this._p.close();
                    if (this._p.contains(d.localPosition)) {
                      widget.onPanDownListener!(d.localPosition, i);
                      this._canRotation = false;
                      return;
                    }
                  }
                }
                widget.onPanDownListener!(d.localPosition, null);
              } else {
                widget.onPanDownListener!(d.localPosition, null);
              }
            }
          },
          onPanCancel: () {
            if (widget.onPanCancelListener != null) {
              widget.onPanCancelListener!();
            }
          },
          onPanStart: (DragStartDetails d) {
            if (widget.allowUserWorldRotation && this._canRotation) {
              this._sp = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
              this._preP = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
            }
            if (widget.onPanStartListener != null) {
              widget.onPanStartListener!(d.localPosition);
            }
          },
          onPanUpdate: (DragUpdateDetails d) {
            if (widget.allowUserWorldRotation && this._canRotation) {
              _rotation(d.localPosition);
            }
            if (widget.onPanUpdateListener != null) {
              widget.onPanUpdateListener!(d.localPosition);
            }
          },
          onPanEnd: (DragEndDetails d) {
            if (widget.onPanEndListener != null) {
              widget.onPanEndListener!();
            }
          },
        );
      } else {
        return GestureDetector(
            child: CustomPaint(
              painter: _Sp3dCanvasPainter(widget),
              size: widget.size,
            ),
            onPanStart: (DragStartDetails d) {
              this._sp = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
              this._preP = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
            },
            onPanUpdate: (DragUpdateDetails d) {
              _rotation(d.localPosition);
            });
      }
    } else {
      return CustomPaint(
        painter: _Sp3dCanvasPainter(widget),
        size: widget.size,
      );
    }
  }

  /// world rotation
  void _rotation(Offset offset) {
    setState(() {
      final Sp3dV3D nowP = Sp3dV3D(offset.dx, offset.dy, 0);
      this._angle += (nowP - this._preP).len();
      if (this._angle > 360) {
        this._angle %= 360;
      }
      final Sp3dV3D diff = nowP - this._sp;
      final Sp3dV3D axis = Sp3dV3D(diff.y, diff.x, 0).nor();
      this.widget.camera.rotate(axis, this._angle * pi / 180);
      this._preP = nowP;
    });
  }
}

class _Sp3dCanvasPainter extends CustomPainter {
  final Sp3dRenderer w;
  final Paint p = Paint();
  final Path path = Path();

  _Sp3dCanvasPainter(this.w) : super(repaint: w.vn);

  @override
  void paint(Canvas canvas, Size size) {
    // カメラで撮影した２次元座標とカメラまでの距離などを含むデータオブジェクトを取得。
    // なお、描画対象外のオブジェクトはここで除外される。
    final List<Sp3dFaceObj> allFaces =
        this.w.camera.getPrams(this.w.world, this.w.worldOrigin);
    // z軸を基準にして遠いところから順番に塗りつぶすために全てのfaceを逆順ソート。
    allFaces.sort((Sp3dFaceObj a, Sp3dFaceObj b) => b.dist.compareTo(a.dist));
    if (w.allowFullCtrl) {
      this.w.world.sortedAllFaces = allFaces;
    }
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
