import 'dart:ui';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/util_color.dart';

///
/// (en)A simple light for shooting Sp3dObj.
///
/// (ja)Sp3dWorldの撮影用のシンプルなライトです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 21:17:02
///
class Sp3dLight {

  final String class_name = 'Sp3dLight';
  final String version = '1';
  Sp3dV3D direction;
  double min_brightness;
  bool apply_stroke;
  bool sync_cam;

  /// Constructor
  /// * [direction] : Light direction(must normalized).
  /// * [min_brightness] : Minimum value of brightness magnification. value is 0.0~1.0.
  /// * [apply_stroke] : If true, apply light to wire frame. Default is false.
  /// * [sync_cam] : If true, the light is always from the same direction as the camera.
  Sp3dLight(this.direction, {this.min_brightness=0.0, this.apply_stroke = false, this.sync_cam = true});

  /// (en)Deep copy the object.
  ///
  /// (ja)このオブジェクトをディープコピーします。
  ///
  Sp3dLight deep_copy(){
    return Sp3dLight(this.direction, min_brightness: this.min_brightness, apply_stroke: this.apply_stroke, sync_cam: this.sync_cam);
  }

  /// (en)Convert the object to a dictionary.
  ///
  /// (ja)このオブジェクトを辞書に変換します。
  ///
  Map<String, dynamic> to_dict(){
    Map<String, dynamic> d = {};
    d['class_name'] = this.class_name;
    d['version'] = this.version;
    d['direction'] = this.direction.to_dict();
    d['min_brightness'] = this.min_brightness;
    d['apply_stroke'] = this.apply_stroke;
    d['sync_cam'] = this.sync_cam;
    return d;
  }

  /// (en)Restore this object from the dictionary.
  ///
  /// (ja)辞書からオブジェクトを復元します。
  ///
  /// * [src] : A dictionary made with to_dict of this class.
  static Sp3dLight from_dict(Map<String, dynamic> src){
    return Sp3dLight(
        Sp3dV3D.from_dict(src['direction']),
        min_brightness: src['is_absolute_position'],
        apply_stroke: src['apply_stroke'],
        sync_cam: src['sync_cam']
    );
  }

  /// (en)Returns the color as a result of this light being applied to a particular surface.
  ///
  /// (ja)特定の面にこのライトが適用された結果としての色を返します。
  ///
  /// * [nsn] : The normalized surface normal vector.
  /// * [cam_theta] : With this, the light is always from the same direction as the camera.
  /// * [material] : The material to which light is applied.
  ///
  /// Returns : [Color(bg),Color(stroke)].
  List<Color> apply(Sp3dV3D nsn, double cam_theta, Sp3dMaterial? material) {
    List<Color> r = [];
    // 光の計算
    // 正規化されたベクトル同士の内積を取ると結果がcosΘになるので、そこから光の拡散度合い（光の強さ）に変換する。
    // RGB値に掛け合わせて明度を変化させるために、内積をさらに0~1の範囲に補正。
    late double brightness;
    if(this.sync_cam){
      brightness = cam_theta.clamp(0.0, 1.0);
    }
    else {
      brightness = Sp3dV3D.dot(nsn, this.direction).clamp(0.0, 1.0);
    }
    if(brightness < this.min_brightness){
      brightness = this.min_brightness;
    }
    // ライトを適用
    if(material==null){
      for(int i = 0; i < 2; i++){
        Color c = Util_Color.random(isConvenient: true);
        r.add(c);
      }
    }
    else {
      Color bg = material.bg;
      r.add(
          Color.fromARGB(
              bg.alpha,
              (brightness * bg.red).toInt(),
              (brightness * bg.green).toInt(),
              (brightness * bg.blue).toInt())
      );
      Color sc = material.stroke_color;
      if(this.apply_stroke) {
        r.add(
            Color.fromARGB(
                sc.alpha,
                (brightness * sc.red).toInt(),
                (brightness * sc.green).toInt(),
                (brightness * sc.blue).toInt())
        );
      }
      else{
        r.add(sc);
      }
    }
    return r;
  }



}