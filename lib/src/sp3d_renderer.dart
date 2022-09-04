import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'sp3d_faceobj.dart';
import 'sp3d_gesture_detector.dart';
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
  final String version = '8';
  final Size size;
  final Sp3dV2D worldOrigin;
  final Sp3dWorld world;
  final Sp3dCamera camera;
  final Sp3dLight light;
  final bool useUserGesture;
  final bool allowUserWorldRotation;
  final bool allowUserWorldZoom;
  final bool checkTouchObj;
  final ValueNotifier<int>? vn;
  final double rotationSpeed;
  final double zoomSpeed;
  final bool isMouseScrollSameVector;

  // タッチリスナの定義。速度の問題があるので、onPanDownでのみ当たり判定の演算を行い、当たり判定があれば情報クラスを返す。
  final void Function(Sp3dGestureDetails details, Sp3dFaceObj?)? onPanDown;
  final void Function(Sp3dGestureDetails details, Sp3dFaceObj?)?
      onSecondPanDown;
  final void Function()? onPanCancel;
  final void Function(Sp3dGestureDetails details)? onPanStart;
  final void Function(Sp3dGestureDetails details)? onPanUpdate;
  final void Function(Sp3dGestureDetails details)? onPanEnd;
  final void Function(Sp3dGestureDetails details)? onPinchStart;
  final void Function(Sp3dGestureDetails details)? onPinchUpdate;
  final void Function(Sp3dGestureDetails details)? onPinchEnd;
  final void Function(Sp3dGestureDetails details)? onMouseScroll;
  final HitTestBehavior behavior;

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
  /// * [allowUserWorldRotation] : If true, allow world rotation by user.
  /// However, when checkTouchObj is true and touch target is exist when onPanDown or onSecondPanDown,
  /// the subsequent rotation and zoom is suppressed.
  /// * [allowUserWorldZoom] : If true, allow world zoom by user. This is operated by pinching in and pinching out.
  /// * [checkTouchObj] : If this is true and allowFullCtrl is true, Returns the information of the object touched when onPanDown.
  /// If false, and if there is no touch target, null is returned by onPanDown.
  /// * [onPanDown] : Callback at user touch initiation.
  /// The arguments of the function to be set are the offset and the object touched at the time of touch.
  /// * [onSecondPanDown] : Callback at user touch initiation of second finger.
  /// * [onPanCancel] : Callback at user touch cancel. It is called instead of onTouchEnd when user touch cancel.
  /// * [onPanCancel] : Callback at user touch cancel.
  /// * [onPanStart] : Callback at user pan start.
  /// * [onPanUpdate] : Callback at user pan update.
  /// * [onPanEnd] : Callback at user pan end.
  /// * [onPinchStart] : Callback at user pinch start.
  /// * [onPinchUpdate] : Callback at user pinch update.
  /// * [onPinchEnd] : Callback at user pinch end.
  /// * [onMouseScroll] : Callback at user mouse scroll. This returns a diffV with the orientation stored in y. Any other value is zero.
  /// * [behavior] : Specification about the hit judgment area of the child widget.
  /// * [vn] : ValueNotifier. If update this notifier.value, custom painter in renderer will repaint.
  /// * [rotationSpeed] : The rotation speed of the camera relative to the amount of swipe by the user.
  /// * [zoomSpeed] : The zoom speed of the camera relative to the amount of pinch by the user.
  /// * [isMouseScrollSameVector] : Controls the zoom direction when scrolling with the mouse.
  const Sp3dRenderer(
      this.size, this.worldOrigin, this.world, this.camera, this.light,
      {Key? key,
      this.useUserGesture = true,
      this.allowUserWorldRotation = true,
      this.allowUserWorldZoom = true,
      this.checkTouchObj = true,
      this.onPanDown,
      this.onSecondPanDown,
      this.onPanCancel,
      this.onPanStart,
      this.onPanUpdate,
      this.onPanEnd,
      this.onPinchStart,
      this.onPinchUpdate,
      this.onPinchEnd,
      this.onMouseScroll,
      this.behavior = HitTestBehavior.opaque,
      this.vn,
      this.rotationSpeed = 1.0,
      this.zoomSpeed = 3.0,
      this.isMouseScrollSameVector = true})
      : super(key: key);

  @override
  Sp3dRendererState createState() => Sp3dRendererState();
}

class Sp3dRendererState extends State<Sp3dRenderer> {
  // 初期値
  static const Sp3dV2D _zero = Sp3dV2D(0, 0);

  // ドラッグ開始位置
  Sp3dV2D _sp = _zero;

  // 現在の軸
  Sp3dV3D _axis = Sp3dV3D(0, 0, 0);

  // 現在の差
  Sp3dV2D _diff = _zero;

  // 以前の差
  Sp3dV2D _lastDiff = _zero;

  // 当たり判定計算用のPath
  final Path _p = Path();

  // 以降の回転や拡大縮小を抑制するかどうかのフラグ
  bool _canRotationAndZoom = true;

  @override
  void initState() {
    super.initState();
  }

  void _panDownAction(Sp3dGestureDetails d, bool isFirstPanDown) {
    if (widget.checkTouchObj) {
      for (Sp3dFaceObj i in widget.world.sortedAllFaces.reversed) {
        _p.reset();
        if (i.vertices2d.length == 3) {
          _p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
          _p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
          _p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
          _p.close();
          if (_p.contains(d.toOffset())) {
            if (isFirstPanDown) {
              widget.onPanDown!(d, i);
            } else {
              widget.onSecondPanDown!(d, i);
            }
            _canRotationAndZoom = false;
            return;
          }
        } else {
          _p.moveTo(i.vertices2d[0].x, i.vertices2d[0].y);
          _p.lineTo(i.vertices2d[1].x, i.vertices2d[1].y);
          _p.lineTo(i.vertices2d[2].x, i.vertices2d[2].y);
          _p.lineTo(i.vertices2d[3].x, i.vertices2d[3].y);
          _p.close();
          if (_p.contains(d.toOffset())) {
            if (isFirstPanDown) {
              widget.onPanDown!(d, i);
            } else {
              widget.onSecondPanDown!(d, i);
            }
            _canRotationAndZoom = false;
            return;
          }
        }
      }
      if (isFirstPanDown) {
        widget.onPanDown!(d, null);
      } else {
        widget.onSecondPanDown!(d, null);
      }
    } else {
      if (isFirstPanDown) {
        widget.onPanDown!(d, null);
      } else {
        widget.onSecondPanDown!(d, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useUserGesture) {
      return Sp3dGestureDetector(
        onPanDown: (Sp3dGestureDetails d) {
          _canRotationAndZoom = true;
          if (widget.onPanDown != null) {
            _panDownAction(d, true);
          }
        },
        onSecondPanDown: (Sp3dGestureDetails d) {
          if (widget.onSecondPanDown != null) {
            _panDownAction(d, false);
          }
        },
        onPanCancel: () {
          endProcess();
          if (widget.onPanCancel != null) {
            widget.onPanCancel!();
          }
        },
        onPanStart: (Sp3dGestureDetails d) {
          if (widget.allowUserWorldRotation && _canRotationAndZoom) {
            _sp = d.nowV;
          }
          if (widget.onPanStart != null) {
            widget.onPanStart!(d);
          }
        },
        onPanUpdate: (Sp3dGestureDetails d) {
          if (widget.allowUserWorldRotation && _canRotationAndZoom) {
            _rotation(d);
          }
          if (widget.onPanUpdate != null) {
            widget.onPanUpdate!(d);
          }
        },
        onPanEnd: (Sp3dGestureDetails d) {
          endProcess();
          if (widget.onPanEnd != null) {
            widget.onPanEnd!(d);
          }
        },
        onPinchStart: (Sp3dGestureDetails d) {
          if (widget.onPinchStart != null) {
            widget.onPinchStart!(d);
          }
        },
        onPinchUpdate: (Sp3dGestureDetails d) {
          if (widget.allowUserWorldZoom && _canRotationAndZoom) {
            _zoom(d);
          }
          if (widget.onPinchUpdate != null) {
            widget.onPinchUpdate!(d);
          }
        },
        onPinchEnd: (Sp3dGestureDetails d) {
          if (widget.onPinchEnd != null) {
            widget.onPinchEnd!(d);
          }
        },
        onScroll: (Sp3dGestureDetails d) {
          if (widget.allowUserWorldZoom && _canRotationAndZoom) {
            _zoom(d);
          }
          if (widget.onMouseScroll != null) {
            widget.onMouseScroll!(d);
          }
        },
        behavior: widget.behavior,
        child: CustomPaint(
          painter: _Sp3dCanvasPainter(widget),
          size: widget.size,
        ),
      );
    } else {
      return CustomPaint(
        painter: _Sp3dCanvasPainter(widget),
        size: widget.size,
      );
    }
  }

  /// world zoom
  void _zoom(Sp3dGestureDetails d) {
    setState(() {
      // y方向の値にズーム量をかけた値でズームする。
      if (widget.isMouseScrollSameVector) {
        widget.camera.focusLength =
            widget.camera.focusLength - (d.diffV.y * widget.zoomSpeed);
      } else {
        widget.camera.focusLength =
            widget.camera.focusLength + (d.diffV.y * widget.zoomSpeed);
      }
      // マイナス値は計算が反転するため許容しない。
      if (widget.camera.focusLength < 0) {
        widget.camera.focusLength = 1;
      }
    });
  }

  /// world rotation
  void _rotation(Sp3dGestureDetails d) {
    setState(() {
      // 始点ベースにして戻り方向を有効にする。
      final Sp3dV2D diff = (d.nowV - _sp) * widget.rotationSpeed;
      // 前の軸から、今の軸へスムーズに移動させる
      _diff = _lastDiff + diff;
      // 前回の回転分を考慮した角度。
      double angle = _diff.len();
      if (angle > 360 || angle < -360) {
        // 360度以上の回転に対応
        _diff = _zero;
        _lastDiff = _zero;
        _sp = d.nowV;
        angle = 0;
      }
      // 回転軸。xとyを反転させる必要がある。
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
    w.world.sortedAllFaces = allFaces;
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
