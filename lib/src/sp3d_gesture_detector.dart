import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:simple_3d_renderer/src/sp3d_v2d.dart';

///
/// (en)A class for realizing various gesture operations for 3D objects.
///
/// (ja)3Dオブジェクトに対する様々なジャスチャー操作を実現するためのクラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2022-09-03 18:43:33
///
class Sp3dGestureDetector extends StatefulWidget {
  final Widget child;
  final void Function(Sp3dGestureDetails details)? onPanDown;
  final void Function(Sp3dGestureDetails details)? onSecondPanDown;
  final void Function()? onPanCancel;
  final void Function(Sp3dGestureDetails details)? onPanStart;
  final void Function(Sp3dGestureDetails details)? onPanUpdate;
  final void Function(Sp3dGestureDetails details)? onPanEnd;
  final void Function(Sp3dGestureDetails details)? onPinchStart;
  final void Function(Sp3dGestureDetails details)? onPinchUpdate;
  final void Function(Sp3dGestureDetails details)? onPinchEnd;
  final void Function(Sp3dGestureDetails details)? onScroll;
  final HitTestBehavior behavior;

  /// * [child] : The child widget.
  /// * [onPanDown] : Callback at user touch initiation.
  /// * [onSecondPanDown] : Callback at user touch initiation of second finger.
  /// * [onPanCancel] : Callback at user touch cancel.
  /// * [onPanStart] : Callback at user pan start.
  /// * [onPanUpdate] : Callback at user pan update.
  /// * [onPanEnd] : Callback at user pan end.
  /// * [onPinchStart] : Callback at user pinch start.
  /// * [onPinchUpdate] : Callback at user pinch update.
  /// * [onPinchEnd] : Callback at user pinch end.
  /// * [onScroll] : Callback at user mouse scroll. This returns a diffV with the orientation stored in y. Any other value is zero.
  /// * [behavior] : Specification about the hit judgment area of the child widget.
  const Sp3dGestureDetector(
      {super.key,
      required this.child,
      this.onPanDown,
      this.onSecondPanDown,
      this.onPanCancel,
      this.onPanStart,
      this.onPanUpdate,
      this.onPanEnd,
      this.onPinchStart,
      this.onPinchUpdate,
      this.onPinchEnd,
      this.onScroll,
      this.behavior = HitTestBehavior.opaque});

  @override
  State<Sp3dGestureDetector> createState() => _Sp3dGestureDetectorState();
}

class _Sp3dGestureDetectorState extends State<Sp3dGestureDetector> {
  /// 各指のタッチイベントを保存する辞書。
  final Map<int, _TouchEvent> _touches = {};

  /// 現在の状態
  EnumGestureType _gType = EnumGestureType.none;

  /// マウススクロールに使用するゼロの値
  static const Sp3dV2D _zero = Sp3dV2D(0, 0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: widget.key,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      onPointerPanZoomStart: _onPointerPanZoomStart,
      onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
      onPointerPanZoomEnd: _onPointerPanZoomEnd,
      onPointerSignal: _onPointerSignal,
      behavior: widget.behavior,
      child: widget.child,
    );
  }

  Sp3dGestureDetails _getFirstGestureDetails(
      int pointer, Offset localPosition) {
    return Sp3dGestureDetails(
        pointer,
        Sp3dV2D(localPosition.dx, localPosition.dy),
        Sp3dV2D(localPosition.dx, localPosition.dy),
        const Sp3dV2D(0, 0));
  }

  Sp3dGestureDetails _getScrollGestureDetails(int pointer, double scrollDelta) {
    if (scrollDelta > 0) {
      return Sp3dGestureDetails(pointer, _zero, _zero, const Sp3dV2D(0, 100));
    } else {
      return Sp3dGestureDetails(pointer, _zero, _zero, const Sp3dV2D(0, -100));
    }
  }

  Sp3dGestureDetails _updateTouchesAndGetGestureDetails(
      int pointer, Offset localPosition) {
    final Sp3dV2D preP =
        Sp3dV2D(_touches[pointer]!.nowP.dx, _touches[pointer]!.nowP.dy);
    final Sp3dV2D nowP = Sp3dV2D(localPosition.dx, localPosition.dy);
    _touches[pointer]!.nowP = localPosition;
    return Sp3dGestureDetails(
        pointer,
        Sp3dV2D(_touches[pointer]!.sP.dx, _touches[pointer]!.sP.dy),
        nowP,
        (_gType == EnumGestureType.tapDown ||
                _gType == EnumGestureType.panUpdate ||
                _gType == EnumGestureType.pointerPan)
            ? nowP - preP
            : _getPinchV(pointer, preP, nowP));
  }

  Sp3dGestureDetails _updateTouchesAndGetGestureDetailsForTrackPadPan(
      int pointer, Offset localDelta) {
    final Sp3dV2D preP =
        Sp3dV2D(_touches[pointer]!.nowP.dx, _touches[pointer]!.nowP.dy);
    final Sp3dV2D nowP = preP + Sp3dV2D(localDelta.dx, localDelta.dy);
    _touches[pointer]!.nowP = Offset(nowP.x, nowP.y);
    return Sp3dGestureDetails(
        pointer,
        Sp3dV2D(_touches[pointer]!.sP.dx, _touches[pointer]!.sP.dy),
        nowP,
        nowP - preP);
  }

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    _gType = EnumGestureType.pointerPanZoomStart;
    _touches[event.pointer] =
        (_TouchEvent(event.pointer, event.localPosition, event.localPosition));
    final Sp3dGestureDetails cds =
        _getFirstGestureDetails(event.pointer, event.localPosition);
    if (widget.onPanDown != null) {
      widget.onPanDown!(cds);
    }
    _gType = EnumGestureType.secondTapDown;
    if (widget.onSecondPanDown != null) {
      widget.onSecondPanDown!(cds);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!_touches.containsKey(event.pointer)) {
      return;
    }
    // switch pan or zoom
    if (event.scale == 1.0) {
      // pan
      final bool isUpdate = _gType == EnumGestureType.pointerPan;
      // if switch
      if (_gType == EnumGestureType.pointerZoom) {
        // マウススクロール扱いでズーム。
        if (widget.onScroll != null) {
          widget.onScroll!(_getScrollGestureDetails(
              event.pointer, event.scale < 1.0 ? 1 : -1));
        }
      }
      _gType = EnumGestureType.pointerPan;
      // must update
      final Sp3dGestureDetails cds =
          _updateTouchesAndGetGestureDetailsForTrackPadPan(
              event.pointer, event.localPanDelta);
      if (isUpdate) {
        if (widget.onPanUpdate != null) {
          widget.onPanUpdate!(cds);
        }
      } else {
        if (widget.onPanStart != null) {
          widget.onPanStart!(cds);
        }
      }
    } else {
      // zoom
      // if switch
      if (_gType == EnumGestureType.pointerPan) {
        if (widget.onPanEnd != null) {
          widget.onPanEnd!(_updateTouchesAndGetGestureDetails(
              event.pointer, event.localPosition));
        }
      }
      _gType = EnumGestureType.pointerZoom;
      // マウススクロール扱いでズーム。
      final Sp3dGestureDetails cds =
          _getScrollGestureDetails(event.pointer, event.scale < 1.0 ? 1 : -1);
      if (widget.onScroll != null) {
        widget.onScroll!(cds);
      }
    }
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    final Sp3dGestureDetails cds =
        _updateTouchesAndGetGestureDetails(event.pointer, event.localPosition);
    if (_gType == EnumGestureType.pointerPan) {
      if (widget.onPanEnd != null) {
        widget.onPanEnd!(cds);
      }
    } else {
      if (widget.onScroll != null) {
        widget.onScroll!(cds);
      }
    }
    // 使い終わったオブジェクトを破棄。
    _touches.remove(event.pointer);
  }

  void _onPointerDown(PointerDownEvent event) {
    _touches[event.pointer] =
        (_TouchEvent(event.pointer, event.localPosition, event.localPosition));
    final Sp3dGestureDetails cds =
        _getFirstGestureDetails(event.pointer, event.localPosition);
    if (_touches.length == 1) {
      _gType = EnumGestureType.tapDown;
      if (widget.onPanDown != null) {
        widget.onPanDown!(cds);
      }
    } else if (_touches.length == 2) {
      _gType = EnumGestureType.secondTapDown;
      if (widget.onSecondPanDown != null) {
        widget.onSecondPanDown!(cds);
      }
    } else {
      _gType = EnumGestureType.unknown;
    }
  }

  /// ２点の距離の変化によってズーム用に変換されたパラメータを返す。
  Sp3dV2D _getPinchV(int pointer, Sp3dV2D preP, Sp3dV2D nowP) {
    Sp3dV2D? other;
    for (_TouchEvent i in _touches.values) {
      if (i.serial != pointer) {
        other = Sp3dV2D(i.nowP.dx, i.nowP.dy);
        break;
      }
    }
    if (other != null) {
      if (Sp3dV2D.dist(other, preP) > Sp3dV2D.dist(other, nowP)) {
        // pinch-in
        return const Sp3dV2D(0, 100);
      } else {
        // pinch-out
        return const Sp3dV2D(0, -100);
      }
    } else {
      return _zero;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_touches.containsKey(event.pointer)) {
      return;
    }
    // must update
    final callbackDetails =
        _updateTouchesAndGetGestureDetails(event.pointer, event.localPosition);
    if (_gType == EnumGestureType.tapDown) {
      _gType = EnumGestureType.panUpdate;
      if (widget.onPanStart != null) {
        widget.onPanStart!(callbackDetails);
      }
    } else if (_gType == EnumGestureType.panUpdate) {
      if (widget.onPanUpdate != null) {
        widget.onPanUpdate!(callbackDetails);
      }
    } else if (_gType == EnumGestureType.secondTapDown) {
      _gType = EnumGestureType.pinchUpdate;
      if (widget.onPinchStart != null) {
        widget.onPinchStart!(callbackDetails);
      }
    } else if (_gType == EnumGestureType.pinchUpdate) {
      if (widget.onPinchUpdate != null) {
        widget.onPinchUpdate!(callbackDetails);
      }
    } else {
      // 何もしない
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_touches.containsKey(event.pointer)) {
      return;
    }
    final callbackDetails =
        _updateTouchesAndGetGestureDetails(event.pointer, event.localPosition);
    if (_gType == EnumGestureType.tapDown) {
      if (widget.onPanCancel != null) {
        widget.onPanCancel!();
      }
    } else if (_gType == EnumGestureType.panUpdate) {
      if (widget.onPanEnd != null) {
        widget.onPanEnd!(callbackDetails);
      }
    } else if (_gType == EnumGestureType.pinchUpdate) {
      if (widget.onPinchEnd != null) {
        widget.onPinchEnd!(callbackDetails);
      }
    } else {
      // 何もしない。EnumGestureType.secondTapDownのままなど。
    }
    // 使い終わったオブジェクトを破棄。
    _touches.remove(event.pointer);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_touches.containsKey(event.pointer)) {
      return;
    }
    _touches[event.pointer]!.nowP = event.localPosition;
    if (_gType == EnumGestureType.tapDown) {
      if (widget.onPanCancel != null) {
        widget.onPanCancel!();
      }
    } else if (_gType == EnumGestureType.panUpdate) {
      if (widget.onPanCancel != null) {
        widget.onPanCancel!();
      }
    } else {
      // 何もしない。EnumGestureType.secondTapDownのままなど。
    }
    // 使い終わったオブジェクトを破棄。
    _touches.remove(event.pointer);
  }

  /// マウススクロールイベントのみを処理する。
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (widget.onScroll != null) {
        widget.onScroll!(
            _getScrollGestureDetails(event.pointer, event.scrollDelta.dy));
      }
    }
  }
}

class _TouchEvent {
  final int serial;
  final Offset sP;
  Offset nowP;

  /// * [serial] : Touch finger serial number.
  /// * [sP] : Touch start position.
  /// * [nowP] : Now finger position.
  _TouchEvent(this.serial, this.sP, this.nowP);
}

class Sp3dGestureDetails {
  final int serial;
  final Sp3dV2D startV;
  final Sp3dV2D nowV;
  final Sp3dV2D diffV;

  /// * [serial] : Touch finger serial number.
  /// * [startV] : The gesture starting point vector. This is local point.
  /// * [nowV] : The now point vector. This is local point.
  /// * [diffV] : For swipe, The difference from the gesture (the current point - pre point).
  /// For pinch or Scroll, pinch-in is (0, -100), pinch-out is (0, 100).
  const Sp3dGestureDetails(this.serial, this.startV, this.nowV, this.diffV);

  /// nowV to Offset.
  Offset toOffset() {
    return Offset(nowV.x, nowV.y);
  }
}

enum EnumGestureType {
  tapDown,
  // Two finger tapped. This is pre mode of change mode to move or scale.
  secondTapDown,
  // One finger swipe.
  panUpdate,
  // Tow finger pinch-in or pinch-out.
  pinchUpdate,
  // Trackpad event(It doesn't happen on the web).
  pointerPanZoomStart,
  pointerPan,
  pointerZoom,
  // Non tap yet.
  none,
  // e.g. 3 tap or over.
  unknown
}
