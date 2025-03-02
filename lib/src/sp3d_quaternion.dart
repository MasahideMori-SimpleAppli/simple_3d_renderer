import 'dart:math';
import 'package:simple_3d/simple_3d.dart';

/// (en) Quaternion class that can be used in conjunction with
/// Sp3dV3D class for rotation control.
///
/// (ja) Sp3dV3Dクラスと連動可能なクォータニオンクラスです。回転制御に利用できます。
class Sp3dQuaternion {
  static const String className = 'Sp3dQuaternion';
  static const String version = '1';
  double w, x, y, z;

  /// Constructor
  Sp3dQuaternion(this.w, this.x, this.y, this.z);

  /// (en) Generates a quaternion with no rotation.
  ///
  /// (ja) 回転なしのクォータニオンを生成します。
  factory Sp3dQuaternion.identity() => Sp3dQuaternion(1, 0, 0, 0);

  /// (en) Generates a quaternion from a rotation axis and angle.
  ///
  /// (ja) 回転軸と回転角からクォータニオンを生成します。
  factory Sp3dQuaternion.fromAxisAngle(Sp3dV3D axis, double angle) {
    double halfAngle = angle / 2;
    double s = sin(halfAngle);
    Sp3dV3D nAxis = axis.nor();
    return Sp3dQuaternion(
        cos(halfAngle), nAxis.x * s, nAxis.y * s, nAxis.z * s);
  }

  /// (en) Returns a deep copy.
  ///
  /// (ja) ディープコピーを返します。
  Sp3dQuaternion deepCopy() => Sp3dQuaternion(w, x, y, z);

  /// Convert to Map.
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['w'] = w;
    d['x'] = x;
    d['y'] = y;
    d['z'] = z;
    return d;
  }

  /// convert from Map.
  static Sp3dQuaternion fromDict(Map<String, dynamic> src) {
    return Sp3dQuaternion(src['w'], src['x'], src['y'], src['z']);
  }

  Sp3dQuaternion operator *(Sp3dQuaternion other) {
    return Sp3dQuaternion(
      w * other.w - x * other.x - y * other.y - z * other.z,
      w * other.x + x * other.w + y * other.z - z * other.y,
      w * other.y - x * other.z + y * other.w + z * other.x,
      w * other.z + x * other.y - y * other.x + z * other.w,
    );
  }

  /// (en) Return the length.
  ///
  /// (ja) 長さを返します。
  double len() => sqrt(w * w + x * x + y * y + z * z);

  /// (en) Returns the new normalized quaternion.
  ///
  /// (ja) 正規化した新しいクォータニオンを返します。
  Sp3dQuaternion nor() {
    double mag = len();
    if (mag > 0) {
      return Sp3dQuaternion(w / mag, x / mag, y / mag, z / mag);
    } else {
      return deepCopy();
    }
  }

  /// (en) Returns a new vector by rotating the specified vector by this quaternion.
  ///
  /// (ja) 指定したベクトルをこのクォータニオンで回転した新しいベクトルを返します。
  Sp3dV3D rotateVector(Sp3dV3D v) {
    Sp3dQuaternion qv = Sp3dQuaternion(0, v.x, v.y, v.z);
    Sp3dQuaternion qConj = conjugate();
    Sp3dQuaternion result = this * qv * qConj;
    return Sp3dV3D(result.x, result.y, result.z);
  }

  /// (en) Interpolates between two quaternions with
  /// spherical linear interpolation.
  ///
  /// (ja) 球面線形補間（Spherical Linear Interpolation）で
  /// 2つのクォータニオン間を補間します。
  Sp3dQuaternion slerp(Sp3dQuaternion other, double t) {
    double dot = w * other.w + x * other.x + y * other.y + z * other.z;
    if (dot.abs() > 0.9995) {
      return Sp3dQuaternion(
        w + t * (other.w - w),
        x + t * (other.x - x),
        y + t * (other.y - y),
        z + t * (other.z - z),
      ).nor();
    }
    dot = dot.clamp(-1, 1);
    final double theta = acos(dot);
    final double sinTheta = sin(theta);
    if (sinTheta.abs() < 0.0001) return this;
    final double a = sin((1 - t) * theta) / sinTheta;
    final double b = sin(t * theta) / sinTheta;
    return Sp3dQuaternion(
      w * a + other.w * b,
      x * a + other.x * b,
      y * a + other.y * b,
      z * a + other.z * b,
    );
  }

  /// (en) Returns a map of Euler angles (roll, pitch, yaw) converted
  /// from this quaternion.
  ///
  /// (ja) このクォータニオンをオイラー角（ロール、ピッチ、ヨー）のマップに変換して返します。
  Map<String, double> toEuler() {
    final double sinRCosP = 2 * (w * x + y * z);
    final double cosRCosP = 1 - 2 * (x * x + y * y);
    final double roll = atan2(sinRCosP, cosRCosP);
    final double sinP = 2 * (w * y - z * x);
    final double pitch = sinP.abs() >= 1 ? pi / 2 * sinP.sign : asin(sinP);
    final double sinYCosP = 2 * (w * z + x * y);
    final double cosYCosP = 1 - 2 * (y * y + z * z);
    final double yaw = atan2(sinYCosP, cosYCosP);
    return {'yaw': yaw, 'pitch': pitch, 'roll': roll};
  }

  /// (en) Returns a quaternion generated from an Euler rotation.
  ///
  /// (ja) オイラー回転からクォータニオンを生成して返します。
  factory Sp3dQuaternion.fromEuler(double yaw, double pitch, double roll) {
    final double cy = cos(yaw * 0.5);
    final double sy = sin(yaw * 0.5);
    final double cp = cos(pitch * 0.5);
    final double sp = sin(pitch * 0.5);
    final double cr = cos(roll * 0.5);
    final double sr = sin(roll * 0.5);
    return Sp3dQuaternion(
      cr * cp * cy + sr * sp * sy,
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
    );
  }

  /// (en) Creates and returns the conjugate quaternion (for inverse rotation).
  ///
  /// (ja) 共役クォータニオン（逆回転用）を作り、返します。
  Sp3dQuaternion conjugate() => Sp3dQuaternion(w, -x, -y, -z);

  /// (en) Creates and returns an inverse quaternion (for canceling rotations).
  ///
  /// (ja) 逆クォータニオン（回転のキャンセル用）を作り、返します。
  Sp3dQuaternion inverse() {
    final double mag2 = w * w + x * x + y * y + z * z;
    return Sp3dQuaternion(w / mag2, -x / mag2, -y / mag2, -z / mag2);
  }
}
