import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en)A class for handling 2D vectors. This class acts as Final and cannot change its value.
///
/// (ja)二次元ベクトルを扱うためのクラスです。このクラスはFinalとして機能し、値を変更できません。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 12:18:31
///
@immutable
class Sp3dV2D {
  static const String className = 'Sp3dV2D';
  static const String version = '9';
  final double x;
  final double y;

  /// Constructor
  /// * [x] : x.
  /// * [y] : y.
  const Sp3dV2D(this.x, this.y);

  /// Deep copy this object.
  Sp3dV2D deepCopy() {
    return Sp3dV2D(x, y);
  }

  /// Creates a copy with only the specified values rewritten.
  /// * [x] : The x coordinate of the 2D vertex.
  /// * [y] : The y coordinate of the 2D vertex.
  Sp3dV2D copyWith({double? x, double? y}) {
    return Sp3dV2D(x ?? this.x, y ?? this.y);
  }

  /// Convert to Map.
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['x'] = x;
    d['y'] = y;
    return d;
  }

  /// convert from Map.
  static Sp3dV2D fromDict(Map<String, dynamic> src) {
    return Sp3dV2D(src['x'], src['y']);
  }

  /// (en)Returns a vector with x and y swapped.
  ///
  /// (ja)xとyを入れ替えたベクトルを返します。
  Sp3dV2D exchangedXY() {
    return Sp3dV2D(y, x);
  }

  /// (en)Return Normalized Vector.
  ///
  /// (ja)正規化したベクトルを返します。
  Sp3dV2D nor() {
    final double length = len();
    if (length == 0) {
      return deepCopy();
    } else {
      return this / length;
    }
  }

  /// (en)Return vector length.
  ///
  /// (ja)長さを返します。
  double len() {
    return sqrt(x * x + y * y);
  }

  /// (en)Return euclidean distance.
  ///
  /// (ja)ユークリッド距離を返します。
  static double dist(Sp3dV2D a, Sp3dV2D b) {
    return (a - b).len();
  }

  /// (en)Computes and returns the Euclidean distance between
  /// this vector and the specified vector.
  ///
  /// (ja)このベクトルと指定ベクトルとの間のユークリッド距離を計算して返します。
  ///
  /// * [other] : other vector.
  double distTo(Sp3dV2D other) {
    return dist(this, other);
  }

  /// (en)Compare while considering the error. Returns true if x, y are all within the e_range.
  ///
  /// (ja)誤差を考慮しつつ比較します。x, y の全てが誤差e_range以内の場合はtrueを返します。
  ///
  /// * [other] : other vector.
  /// * [eRange] : The range of error to allow. This must be a positive number.
  bool equals(Sp3dV2D other, double eRange) {
    return x - eRange <= other.x &&
        other.x <= x + eRange &&
        y - eRange <= other.y &&
        other.y <= y + eRange;
  }

  /// (en)Returns a new vector that rotates this vector.
  ///
  /// (ja)このベクトルを回転した新しいベクトルを返します。
  ///
  /// * [origin] : the origin of rotation.
  /// * [radian] : radian = degree * pi / 180.
  Sp3dV2D rotated(Sp3dV2D origin, double radian) {
    final Sp3dV2D diff = this - origin;
    final double r = diff.len();
    final double theta = atan2(diff.y, diff.x) + radian;
    return Sp3dV2D(origin.x + r * cos(theta), origin.y + r * sin(theta));
  }

  /// (en)Returns the clockwise angle of this vector.
  /// The unit of the return value is radians.
  ///
  /// (ja)このベクトルの時計回りの角度を返します。
  /// 戻り値の単位はラジアンです。
  double direction() {
    return atan2(y, x);
  }

  /// (en)Computes and returns the angle between vectorA
  /// and the vectorB.
  /// The unit of the return value is radians.
  ///
  /// (ja)このベクトルaとベクトルbとの間の角度を計算して返します。
  /// 戻り値の単位はラジアンです。
  ///
  /// * [a] : vector a.
  /// * [b] : vector b.
  /// * [origin] : the origin.
  static double angle(Sp3dV2D a, Sp3dV2D b,
      {Sp3dV2D origin = const Sp3dV2D(0, 0)}) {
    double v1 = (a.x - origin.x) * (b.y - origin.y) -
        (a.y - origin.y) * (b.x - origin.x);
    double v2 = (a.x - origin.x) * (b.x - origin.x) +
        (a.y - origin.y) * (b.y - origin.y);
    return atan2(v1, v2);
  }

  /// (en)Computes and returns the angle between this vector
  /// and the specified vector.
  /// The unit of the return value is radians.
  ///
  /// (ja)このベクトルと指定ベクトルとの間の角度を計算して返します。
  /// 戻り値の単位はラジアンです。
  ///
  /// * [other] : other vector.
  /// * [origin] : the origin.
  double angleTo(Sp3dV2D other, {Sp3dV2D origin = const Sp3dV2D(0, 0)}) {
    return angle(this, other);
  }

  /// (en)Converts this vector to an offset and returns it.
  ///
  /// (ja)このベクトルをオフセットに変換して返します。
  Offset toOffset() {
    return Offset(x, y);
  }

  /// (en)Convert from offset to vector.
  ///
  /// (ja)オフセットからベクトルに変換します。
  static Sp3dV2D fromOffset(Offset offset) {
    return Sp3dV2D(offset.dx, offset.dy);
  }

  /// (en)Return dot product.
  ///
  /// (ja)ドット積を返します。
  static double dot(Sp3dV2D a, Sp3dV2D b) {
    return a.x * b.x + a.y * b.y;
  }

  /// (en)Return dot product.
  ///
  /// (ja)ドット積を返します。
  double dotTo(Sp3dV2D other) {
    return dot(this, other);
  }

  /// (en)Converts this vector to a three-dimensional vector and returns it.
  /// The z-axis value is initialized to 0.
  ///
  /// (ja)このベクトルを三次元ベクトルに変換して返します。
  /// z軸の値は0で初期化されます。
  Sp3dV3D toV3D() {
    return Sp3dV3D(x, y, 0);
  }

  /// (en)Returns the angle of the line from 0 to 360 degrees.
  ///
  /// (ja) 線の角度を0～360度で返します。
  ///
  /// * [sp] : Line start point.
  /// * [ep] : Line end point.
  static double angleFromLine(Sp3dV2D sp, Sp3dV2D ep) {
    double r = (ep - sp).direction() / Sp3dConstantValues.toRadian;
    if (r < 0) {
      r = 360 + r;
    }
    return r;
  }

  /// (en)This function considers the error in the comparison.
  /// Returns true if v is within error e_range with respect to c.
  ///
  /// (ja)誤差を考慮しつつ比較します。
  /// vがcに対して誤差e_range以内の場合はtrueを返します。
  ///
  /// * [v] : Target value.
  /// * [c] : Compare value.
  /// * [eRange] : The range of error to allow. This must be a positive number.
  static bool errorTolerance(double v, double c, double eRange) {
    return c - eRange <= v && v <= c + eRange;
  }

  Sp3dV2D operator +(Sp3dV2D v) {
    return Sp3dV2D(x + v.x, y + v.y);
  }

  Sp3dV2D operator -(Sp3dV2D v) {
    return Sp3dV2D(x - v.x, y - v.y);
  }

  Sp3dV2D operator *(num scalar) {
    return Sp3dV2D(x * scalar, y * scalar);
  }

  Sp3dV2D operator /(num scalar) {
    return Sp3dV2D(x / scalar, y / scalar);
  }

  @override
  bool operator ==(Object other) {
    if (other is Sp3dV2D) {
      return x == other.x && y == other.y;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    return result;
  }

  @override
  String toString() {
    return '[$x,$y]';
  }
}
