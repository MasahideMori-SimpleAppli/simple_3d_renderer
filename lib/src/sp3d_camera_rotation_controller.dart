import 'package:simple_3d/simple_3d.dart';
import 'dart:math';
import '../simple_3d_renderer.dart';

///
/// (en)Class for adjusting camera rotation.
/// Creating a subclass and giving it to Sp3dRenderer allows complex camera control.
/// (ja)カメラの回転を調整するためのクラスです。
/// サブクラスを作ってSp3dRendererに与えることで複雑なカメラコントロールが可能になります。
///
/// Author Masahide Mori
///
/// First edition creation date 2023-01-02 11:41:05
///
class Sp3dCameraRotationController {
  static const double _toRadian = pi / 180;

  String get className => 'Sp3dCameraRotationController';

  String get version => '1';

  // 回転速度
  double rotationSpeed;

  // 初期値
  static const Sp3dV2D _zero = Sp3dV2D(0, 0);

  // ドラッグ開始位置（Sp3dRenderer内部から上書きされます）
  Sp3dV2D sp = _zero;

  // 現在の軸
  Sp3dV3D axis = Sp3dV3D(0, 0, 0);

  // 現在の差
  Sp3dV2D diff = _zero;

  // 以前の差
  Sp3dV2D lastDiff = _zero;

  /// Constructor
  /// * [rotationSpeed] : The rotation speed of the camera relative to the amount of swipe by the user.
  /// * [sp] : The drag start position. No need to specify in normal cases.
  /// * [axis] : Rotation axis. No need to specify in normal cases.
  /// * [diff] : Parameter for calculation of rotation. No need to specify in normal cases.
  /// * [lastDiff] : Parameter for calculation of rotation. No need to specify in normal cases.
  Sp3dCameraRotationController(
      {this.rotationSpeed = 1.0,
      this.sp = _zero,
      Sp3dV3D? axis,
      this.diff = _zero,
      this.lastDiff = _zero}) {
    this.axis = axis ?? Sp3dV3D(0, 0, 0);
  }

  /// deep copy.
  Sp3dCameraRotationController deepCopy() {
    return Sp3dCameraRotationController(
        rotationSpeed: rotationSpeed,
        sp: sp.deepCopy(),
        axis: axis.deepCopy(),
        diff: diff.deepCopy(),
        lastDiff: lastDiff.deepCopy());
  }

  /// Used to save state.
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['rotation_speed'] = rotationSpeed;
    d['sp'] = sp.toDict();
    d['axis'] = axis.toDict();
    d['diff'] = diff.toDict();
    d['last_diff'] = lastDiff.toDict();
    return d;
  }

  /// Used to restore state.
  static Sp3dCameraRotationController fromDict(Map<String, dynamic> src) {
    return Sp3dCameraRotationController(
        rotationSpeed: src['rotation_speed'],
        sp: Sp3dV2D.fromDict(src['sp']),
        axis: Sp3dV3D.fromDict(src['axis']),
        diff: Sp3dV2D.fromDict(src['diff']),
        lastDiff: Sp3dV2D.fromDict(src['last_diff']));
  }

  /// (en)A method that rotates the camera according to the user's gesture.
  /// By providing a subclass that overrides this method,
  /// you can control the rotate of the camera in detail.
  ///
  /// (ja)カメラに対してユーザーのジェスチャに応じた回転を与えるメソッドです。
  /// このメソッドをオーバーライドしたサブクラスを与えることで、
  /// カメラの回転を詳細にコントロールできます。
  ///
  /// * [camera] : The camera object.
  /// * [d] : Gesture information.
  void apply(Sp3dCamera camera, Sp3dGestureDetails d) {
    // 始点ベースにして戻り方向を有効にする。
    final Sp3dV2D mDiff = (d.nowV - sp) * rotationSpeed;
    // 前の軸から、今の軸へスムーズに移動させる
    diff = lastDiff + mDiff;
    // 前回の回転分を考慮した角度。
    double angle = diff.len();
    if (angle > 360 || angle < -360) {
      // 360度以上の回転に対応
      diff = _zero;
      lastDiff = _zero;
      sp = d.nowV;
      angle = 0;
    }
    // 回転軸。xとyを反転させる必要がある。
    axis = Sp3dV3D(diff.y, diff.x, 0).nor();
    camera.rotate(axis, angle * _toRadian);
  }

  /// run onPanCancel or onPanEnd.
  void endProcess() {
    lastDiff = diff;
  }
}
