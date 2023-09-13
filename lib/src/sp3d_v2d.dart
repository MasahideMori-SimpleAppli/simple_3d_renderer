import 'dart:math';
import 'package:flutter/material.dart';

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
  final String className = 'Sp3dV2D';
  final String version = '6';
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
  Sp3dV2D exchangeXY() {
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
