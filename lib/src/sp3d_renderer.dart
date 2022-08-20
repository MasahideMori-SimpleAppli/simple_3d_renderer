import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'sp3d_faceobj.dart';
import 'sp3d_light.dart';
import 'sp3d_world.dart';
import 'sp3d_camera.dart';
import 'sp3d_v2d.dart';

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
  final String version = '7';
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
  final double rotationSpeed;

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
  /// * [rotationSpeed] : The rotation speed of the camera relative to the amount of swipe by the user.
  const Sp3dRenderer(
      this.size, this.worldOrigin, this.world, this.camera, this.light,
      {this.useUserGesture = true,
      this.allowFullCtrl = false,
      this.allowUserWorldRotation = true,
      this.checkTouchObj = true,
      this.onPanDownListener,
      this.onPanCancelListener,
      this.onPanStartListener,
      this.onPanUpdateListener,
      this.onPanEndListener,
      this.vn,
      this.rotationSpeed = 1.0,
      Key? key})
      : super(key: key);

  @override
  Sp3dRendererState createState() => Sp3dRendererState();
}

class Sp3dRendererState extends State<Sp3dRenderer> {
  // ドラッグ開始位置
  Sp3dV3D _sp = Sp3dV3D(0, 0, 0);

  // 現在の軸
  Sp3dV3D _axis = Sp3dV3D(0, 0, 0);

  // 現在の差
  Sp3dV3D _diff = Sp3dV3D(0, 0, 0);

  // 以前の差
  Sp3dV3D _lastDiff = Sp3dV3D(0, 0, 0);

  // 当たり判定計算用のPath
  final Path _p = Path();

  // 以降の回転を抑制するかどうかのフラグ
  bool _canRotation = true;

  @override
  void initState() {
    super.initState();
  }

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
            _canRotation = true;
            if (widget.onPanDownListener != null) {
              if (widget.checkTouchObj) {
                for (Sp3dFaceObj i in widget.world.sortedAllFaces.reversed) {
                  _p.reset();
                  if (i.vertices2d.length == 3) {
                    _p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
                    _p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
                    _p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
                    _p.close();
                    if (_p.contains(d.localPosition)) {
                      widget.onPanDownListener!(d.localPosition, i);
                      _canRotation = false;
                      return;
                    }
                  } else {
                    _p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
                    _p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
                    _p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
                    _p.lineTo(i.vertices2d[3].x, i.vertices2d[3].y);
                    _p.close();
                    if (_p.contains(d.localPosition)) {
                      widget.onPanDownListener!(d.localPosition, i);
                      _canRotation = false;
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
            endProcess();
            if (widget.onPanCancelListener != null) {
              widget.onPanCancelListener!();
            }
          },
          onPanStart: (DragStartDetails d) {
            if (widget.allowUserWorldRotation && _canRotation) {
              _sp = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
            }
            if (widget.onPanStartListener != null) {
              widget.onPanStartListener!(d.localPosition);
            }
          },
          onPanUpdate: (DragUpdateDetails d) {
            if (widget.allowUserWorldRotation && _canRotation) {
              _rotation(d.localPosition);
            }
            if (widget.onPanUpdateListener != null) {
              widget.onPanUpdateListener!(d.localPosition);
            }
          },
          onPanEnd: (DragEndDetails d) {
            endProcess();
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
            _sp = Sp3dV3D(d.localPosition.dx, d.localPosition.dy, 0);
          },
          onPanUpdate: (DragUpdateDetails d) {
            _rotation(d.localPosition);
          },
          onPanCancel: () {
            endProcess();
          },
          onPanEnd: (DragEndDetails d) {
            endProcess();
          },
        );
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
      // 始点ベースにして戻り方向を有効にする。
      final Sp3dV3D diff = (nowP - _sp) * widget.rotationSpeed;
      // 前の軸から、今の軸へスムーズに移動させる
      _diff = _lastDiff + diff;
      // 前回の回転分を考慮した角度。
      double angle = _diff.len();
      if (angle > 360 || angle < -360) {
        // 360度以上の回転に対応
        _diff.x = 0.0;
        _diff.y = 0.0;
        _diff.z = 0.0;
        _lastDiff = Sp3dV3D(0, 0, 0);
        _sp = nowP;
        angle = 0;
      }
      // 回転軸。
      _axis = Sp3dV3D(_diff.y, _diff.x, 0).nor();
      widget.camera.rotate(_axis, angle * pi / 180);
    });
  }

  /// run onPanCancel or onPanEnd.
  void endProcess() {
    _lastDiff = _diff;
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
        w.camera.getPrams(w.world, w.worldOrigin);
    // z軸を基準にして遠いところから順番に塗りつぶすために全てのfaceを逆順ソート。
    allFaces.sort((Sp3dFaceObj a, Sp3dFaceObj b) => b.dist.compareTo(a.dist));
    if (w.allowFullCtrl) {
      w.world.sortedAllFaces = allFaces;
    }
    // 描画
    for (final Sp3dFaceObj fo in allFaces) {
      // パスを描画
      // マテリアルが設定されていない時は描画しない。
      if (fo.face.materialIndex != null) {
        final Sp3dMaterial material = fo.obj.materials[fo.face.materialIndex!];
        final List<Color> colors = w.light.apply(fo.nsn, fo.camTheta, material);
        if (material.isFill) {
          if (material.imageIndex != null) {
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
            path.moveTo(fo.vertices2d[0].x, fo.vertices2d[0].y);
            for (int i = 1; i < fo.vertices2d.length; i++) {
              path.lineTo(fo.vertices2d[i].x, fo.vertices2d[i].y);
            }
            path.close();
            canvas.drawPath(path, p);
            path.reset();
          }
        }
        // 外枠の描画
        if (material.strokeWidth > 0) {
          p.color = colors[1];
          p.strokeWidth = material.strokeWidth;
          p.strokeCap = StrokeCap.butt;
          p.style = PaintingStyle.stroke;
          path.moveTo(fo.vertices2d[0].x, fo.vertices2d[0].y);
          for (int i = 1; i < fo.vertices2d.length; i++) {
            path.lineTo(fo.vertices2d[i].x, fo.vertices2d[i].y);
          }
          path.close();
          canvas.drawPath(path, p);
          path.reset();
        }
      }
    }
  }

  @override
  bool shouldRepaint(_Sp3dCanvasPainter p) {
    return true;
  }
}
