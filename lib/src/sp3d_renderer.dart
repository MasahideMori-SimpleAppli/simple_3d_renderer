import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'sp3d_camera_rotation_controller.dart';
import 'sp3d_faceobj.dart';
import 'sp3d_gesture_detector.dart';
import 'sp3d_light.dart';
import 'sp3d_world.dart';
import 'sp3d_camera.dart';
import 'sp3d_v2d.dart';
import 'sp3d_camera_zoom_controller.dart';

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
  String get className => 'Sp3dRenderer';

  String get version => '11';
  final Size size;
  final Sp3dV2D worldOrigin;
  final Sp3dWorld world;
  final Sp3dCamera camera;
  final Sp3dLight light;
  final bool useUserGesture;
  final bool allowUserWorldRotation;
  final bool allowUserWorldZoom;
  final bool checkTouchObj;
  late final ValueNotifier<int> vn;
  final double pinchZoomSpeed;
  final double mouseZoomSpeed;
  final bool isMouseScrollSameVector;
  final Sp3dCameraZoomController zoomController;
  final bool useClipping;
  late final Sp3dCameraRotationController rotationController;

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
  /// * [pinchZoomSpeed] : The zoom speed of the camera relative to the amount of pinch by the user.
  /// * [mouseZoomSpeed] : The zoom speed of the camera relative to the amount of mouse scroll by the user.
  /// * [isMouseScrollSameVector] : Controls the zoom direction when scrolling with the mouse.
  /// * [zoomController] : Optional argument if you want non-linear camera zoom behavior.
  /// * [useClipping] : If true, the excess will be clipped.
  /// * [rotationController] : Optional argument if you want more control over the user's camera rotation.
  Sp3dRenderer(this.size, this.worldOrigin, this.world, this.camera, this.light,
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
      ValueNotifier<int>? vn,
      this.pinchZoomSpeed = 3.0,
      this.mouseZoomSpeed = 20.0,
      this.isMouseScrollSameVector = true,
      this.zoomController = const Sp3dCameraZoomController(),
      this.useClipping = false,
      Sp3dCameraRotationController? rotationController})
      : super(key: key) {
    this.vn = vn ?? ValueNotifier(0);
    this.rotationController =
        rotationController ?? Sp3dCameraRotationController();
  }

  @override
  Sp3dRendererState createState() => Sp3dRendererState();
}

class Sp3dRendererState extends State<Sp3dRenderer> {
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

  /// If flag true, Enable clipping.
  Widget _clippingWrap(Widget w) {
    if (widget.useClipping) {
      return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          clipBehavior: Clip.antiAlias,
          child: w);
    } else {
      return w;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useUserGesture) {
      return _clippingWrap(Sp3dGestureDetector(
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
          widget.rotationController.endProcess();
          if (widget.onPanCancel != null) {
            widget.onPanCancel!();
          }
        },
        onPanStart: (Sp3dGestureDetails d) {
          if (widget.allowUserWorldRotation && _canRotationAndZoom) {
            widget.rotationController.sp = d.nowV;
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
          widget.rotationController.endProcess();
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
            _zoom(d, false);
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
            _zoom(d, true);
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
      ));
    } else {
      return _clippingWrap(CustomPaint(
        painter: _Sp3dCanvasPainter(widget),
        size: widget.size,
      ));
    }
  }

  /// world zoom
  void _zoom(Sp3dGestureDetails d, bool isMouse) {
    final double mulValue =
        isMouse ? widget.mouseZoomSpeed : widget.pinchZoomSpeed;
    final zoomV = widget.isMouseScrollSameVector
        ? d.diffV.y * mulValue * -1
        : d.diffV.y * mulValue;
    widget.zoomController.apply(widget.camera, zoomV, isMouse);
    widget.vn.value += 1;
  }

  /// world rotation
  void _rotation(Sp3dGestureDetails d) {
    widget.rotationController.apply(widget.camera, d);
    widget.vn.value += 1;
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
