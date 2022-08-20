import 'dart:math';
import 'dart:ui';

/// (en)A utility related to color.
///
/// (ja)カラー周りのユーティリティです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-05-14 14:25:59
///
class UtilColor {
  /// (en)Converts the double value specified by 0 to 1 to RGBA.
  ///
  /// (ja)0～1で指定したdouble値をRGBAに変換します。
  ///
  /// * [r] : red.
  /// * [g] : green.
  /// * [b] : blue.
  /// * [o] : opacity.
  ///
  /// Returns Color obj.
  static Color toRGBAd(double r, double g, double b, {double o = 1}) {
    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), o);
  }

  /// (en)Converts the int value specified from 0 to 255 to RGBA.
  ///
  /// (ja)0～255で指定したint値をRGBAに変換します。
  ///
  /// * [r] : red.
  /// * [g] : green.
  /// * [b] : blue.
  /// * [o] : opacity.
  ///
  /// Returns Color obj.
  static Color toRGBAi(int r, int g, int b, {int o = 255}) {
    return Color.fromARGB(o, r, g, b);
  }

  /// (en)Returns a random color.
  ///
  /// (ja)ランダムなカラーを返します。
  ///
  /// * [isConvenient] : (en)If true, it is not just random, but one of rgb is fixed at the maximum value or fixed at 50%.
  /// This produces distinctly different colors.
  /// (ja)trueの場合、単なるランダムでは無く、rgbのどれかを最大値で固定するか、50%で固定します。
  /// これにより、はっきりとした異なる色を生成します.
  ///
  /// Returns Color obj.
  static Color random({bool isConvenient = true}) {
    Random rand = Random();
    List<List<List<double>>> cList = [
      [
        [1, rand.nextDouble(), rand.nextDouble()],
        [rand.nextDouble(), 1, rand.nextDouble()],
        [rand.nextDouble(), rand.nextDouble(), 1]
      ],
      [
        [0.5, rand.nextDouble(), rand.nextDouble()],
        [rand.nextDouble(), 0.5, rand.nextDouble()],
        [rand.nextDouble(), rand.nextDouble(), 0.5]
      ]
    ];
    int select = rand.nextInt(2);
    int index = rand.nextInt(3);
    if (isConvenient) {
      return toRGBAd(
        cList[select][index][0],
        cList[select][index][1],
        cList[select][index][2],
      );
    } else {
      return toRGBAd(rand.nextDouble(), rand.nextDouble(), rand.nextDouble());
    }
  }

  /// (en)Darkens the specified amount at the maximum.
  ///
  /// (ja)最大で指定量暗くします。
  ///
  /// * [c] : src color.
  /// * [level] : Maximum value to subtract from rgb.
  ///
  /// Returns Color obj.
  static Color toDark(Color c, int level) {
    int r = c.red - level >= 0 ? c.red - level : 0;
    int g = c.green - level >= 0 ? c.green - level : 0;
    int b = c.blue - level >= 0 ? c.blue - level : 0;
    return Color.fromARGB(c.alpha, r, g, b);
  }
}
