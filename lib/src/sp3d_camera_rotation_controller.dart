import 'package:simple_3d/simple_3d.dart';
import '../simple_3d_renderer.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en)Class for adjusting camera rotation.
/// Creating a subclass and giving it to Sp3dRenderer allows complex camera control.
///
/// (ja)カメラの回転を調整するためのクラスです。
/// サブクラスを作ってSp3dRendererに与えることで複雑なカメラコントロールが可能になります。
///
/// Author Masahide Mori
///
/// First edition creation date 2023-01-02 11:41:05
///
class Sp3dCameraRotationController {
  static const String className = 'Sp3dCameraRotationController';
  static const String version = '3';

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

  // 特定のカメラでのみ使用する、追尾したい対象の座標。
  late Sp3dV3D lookAtTarget;

  /// Constructor
  /// * [rotationSpeed] : The rotation speed of the camera relative to the amount of swipe by the user.
  /// * [sp] : The drag start position. No need to specify in normal cases.
  /// * [axis] : Rotation axis. No need to specify in normal cases.
  /// * [diff] : Parameter for calculation of rotation. No need to specify in normal cases.
  /// * [lastDiff] : Parameter for calculation of rotation. No need to specify in normal cases.
  /// * [lookAtTarget] : When rotating, the camera automatically controls
  /// its attitude so that it always captures this target.
  /// This parameter is only valid when using Sp3dFreeLookCamera.
  Sp3dCameraRotationController(
      {this.rotationSpeed = 1.0,
      this.sp = _zero,
      Sp3dV3D? axis,
      this.diff = _zero,
      this.lastDiff = _zero,
      Sp3dV3D? lookAtTarget}) {
    this.axis = axis ?? Sp3dV3D(0, 0, 0);
    this.lookAtTarget = lookAtTarget ?? Sp3dV3D(0, 0, 0);
  }

  /// deep copy.
  Sp3dCameraRotationController deepCopy() {
    return Sp3dCameraRotationController(
        rotationSpeed: rotationSpeed,
        sp: sp.deepCopy(),
        axis: axis.deepCopy(),
        diff: diff.deepCopy(),
        lastDiff: lastDiff.deepCopy(),
        lookAtTarget: lookAtTarget.deepCopy());
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
    d['look_at_target'] = lookAtTarget.toDict();
    return d;
  }

  /// Used to restore state.
  static Sp3dCameraRotationController fromDict(Map<String, dynamic> src) {
    Sp3dV3D mLookAtTarget = Sp3dV3D(0, 0, 0);
    if (src.containsKey('look_at_target')) {
      mLookAtTarget = Sp3dV3D.fromDict(src['look_at_target']);
    }
    return Sp3dCameraRotationController(
        rotationSpeed: src['rotation_speed'],
        sp: Sp3dV2D.fromDict(src['sp']),
        axis: Sp3dV3D.fromDict(src['axis']),
        diff: Sp3dV2D.fromDict(src['diff']),
        lastDiff: Sp3dV2D.fromDict(src['last_diff']),
        lookAtTarget: mLookAtTarget);
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
    if (camera is Sp3dFreeLookCamera) {
      // 差分から直接計算する。
      final Sp3dV2D mDiff = d.diffV * rotationSpeed;
      // 現在のカメラ位置からターゲットまでのベクトルと距離を算出。
      final Sp3dV3D toTarget = camera.position - lookAtTarget;
      final double radius = toTarget.len();
      // マウスの移動量を回転角度に変換する。
      final double yawAngle = -mDiff.x * 0.017; // 水平回転。0.017は操作感のための補正。
      final double pitchAngle = -mDiff.y * 0.017; // 垂直回転。
      final Sp3dQuaternion qYaw =
          Sp3dQuaternion.fromAxisAngle(camera.up, yawAngle);
      final Sp3dQuaternion qPitch =
          Sp3dQuaternion.fromAxisAngle(camera.right, pitchAngle);
      final Sp3dQuaternion qCombined = (qYaw * qPitch).nor();
      final Sp3dV3D direction = qCombined.rotateVector(toTarget.nor());
      // カメラを新しい位置に移動し、ターゲット方向に向きを設定。
      camera.move(lookAtTarget + direction * radius);
      camera.lookAt(lookAtTarget);
    } else {
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
      camera.rotate(axis, angle * Sp3dConstantValues.toRadian);
    }
  }

  /// run onPanCancel or onPanEnd.
  void endProcess() {
    lastDiff = diff;
  }
}
