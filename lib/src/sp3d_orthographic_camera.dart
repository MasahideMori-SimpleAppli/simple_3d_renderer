import 'package:simple_3d/simple_3d.dart';

import 'sp3d_camera.dart';
import 'sp3d_v2d.dart';

/// (en)It is a camera for shooting Sp3dWorld.
/// If use this, to ignore the z-axis value.
/// However, please note that the lights are z-dependent.
///
/// (ja)Sp3dWorldの撮影用カメラです。
/// これを使用するとz軸の値を無視して撮影します。
/// ただし、ライトについてはz軸依存になるので注意してください。
///
/// Author Masahide Mori
///
/// First edition creation date 2022-12-18 17:13:37
///
class Sp3dOrthographicCamera extends Sp3dCamera {
  static const String className = 'Sp3dOrthographicCamera';
  static const String version = '3';

  /// Constructor
  /// * [position] : Camera position in the world.
  /// * [focusLength] : Focus length.
  /// * [rotateAxis] : The axis of rotation of this camera. Normalization is required. Default value is (1,0,0).
  /// * [radian] : The rotation angle of this camera. The unit is radians. radian = degree * pi / 180.
  /// * [isAllDrawn] : If True, Draw all objects. If False, the blind spot from the camera will not be drawn.
  Sp3dOrthographicCamera(Sp3dV3D position, double focusLength,
      {Sp3dV3D? rotateAxis, double radian = 0, bool isAllDrawn = false})
      : super(position, focusLength,
            rotateAxis: rotateAxis, radian: radian, isAllDrawn: isAllDrawn);

  @override
  List<Sp3dV2D> convert(Sp3dObj obj, Sp3dV2D origin) {
    List<Sp3dV2D> r = [];
    for (Sp3dV3D i in obj.vertices) {
      final Sp3dV3D v = i.rotated(rotateAxis, radian);
      r.add(Sp3dV2D(
          origin.x + (v.x - position.x), origin.y + (position.y - v.y)));
    }
    return r;
  }

  /// Used to save state.
  @override
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['position'] = position.toDict();
    d['focus_length'] = focusLength;
    d['rotate_axis'] = rotateAxis.toDict();
    d['radian'] = radian;
    d['is_all_drawn'] = isAllDrawn;
    return d;
  }

  /// Used to restore state.
  static Sp3dOrthographicCamera fromDict(Map<String, dynamic> src) {
    return Sp3dOrthographicCamera(
        Sp3dV3D.fromDict(src['position']), src['focus_length'],
        rotateAxis: Sp3dV3D.fromDict(src['rotate_axis']),
        radian: src['radian'],
        isAllDrawn:
            src.containsKey('is_all_drawn') ? src['is_all_drawn'] : false);
  }
}
