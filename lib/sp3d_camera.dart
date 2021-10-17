import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/sp3d_faceobj.dart';
import 'package:simple_3d_renderer/sp3d_v2d.dart';
import 'package:simple_3d_renderer/sp3d_world.dart';

/// (en)It is a camera for shooting Sp3dWorld.
///
/// (ja)Sp3dWorldの撮影用カメラです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 12:05:24
///
class Sp3dCamera {

  final String class_name = 'Sp3dCamera';
  final String version = '2';
  Sp3dV3D position;
  double focus_length;
  late Sp3dV3D rotate_axis;
  double radian;
  // 内部計算でだけ使用する値。移動と回転を分離し、バッファするのに必要。
  late Sp3dV3D rotated_position;

  /// Constructor
  /// * [position] : Camera position in the world.
  /// * [focus_length] : Focus length.
  /// * [rotate_axis] : The axis of rotation of this camera. Normalization is required. Default value is (1,0,0).
  /// * [radian] : The rotation angle of this camera. The unit is radians. radian = degree * pi / 180.
  Sp3dCamera(this.position, this.focus_length, {rotate_axis, this.radian=0}) {
    this.rotate_axis = rotate_axis ?? Sp3dV3D(1.0, 0.0, 0.0);
    this.rotate(this.rotate_axis, this.radian);
  }

  Sp3dCamera deep_copy(){
    return Sp3dCamera(
        this.position.deep_copy(),
        this.focus_length,
        rotate_axis: this.rotate_axis.deep_copy(),
        radian: this.radian);
  }

  Map<String, dynamic> to_dict(){
    Map<String, dynamic> d = {};
    d['class_name'] = this.class_name;
    d['version'] = this.version;
    d['position'] = this.position.to_dict();
    d['focus_length'] = this.focus_length;
    d['rotate_axis'] = this.rotate_axis.to_dict();
    d['radian'] = this.radian;
    return d;
  }

  static Sp3dCamera from_dict(Map<String, dynamic> src){
    return Sp3dCamera(
        Sp3dV3D.from_dict(src['position']),
        src['focus_length'],
        rotate_axis: Sp3dV3D.from_dict(src['rotate_axis']),
        radian: src['radian']);
  }

  /// (en)Move the position of this camera.
  ///
  /// (ja)このカメラの位置を移動します。
  ///
  /// * [position] : Where to move this camera.
  ///
  /// Returns this.
  Sp3dCamera move(Sp3dV3D position) {
    this.position = position;
    this.rotate(this.rotate_axis, this.radian);
    return this;
  }

  /// (en)Rotate this camera.
  ///
  /// (ja)このカメラの向きを変更します。
  ///
  /// * [nor_axis] : Camera rotation axis. Normalization is required.
  /// * [radian] : Camera rotation. radian = degree * pi / 180.
  ///
  /// Returns this.
  Sp3dCamera rotate(Sp3dV3D nor_axis, double radian) {
    this.rotate_axis = nor_axis;
    this.radian = radian;
    this.rotated_position = this.position.rotated(this.rotate_axis, -1 * radian);
    return this;
  }

  /// (en)Take a picture of an object on the world with this camera.
  /// The vertex coordinates of the object are converted to 2D coordinates for screen display and returned.
  ///
  /// (ja)カメラでワールド上のオブジェクトを撮影します。オブジェクトの頂点座標が画面表示用の２次元の座標に変換されて返されます。
  ///
  /// * [obj] : Sp3dObj in the world.
  /// * [origin] : The world origin in canvas.
  ///
  /// Returns Clip coordinates.
  List<Sp3dV2D> convert(Sp3dObj obj, Sp3dV2D origin) {
    List<Sp3dV2D> r = [];
    for(Sp3dV3D i in obj.vertices){
      // 実質的にはワールド側全体が回転している。このため、get_pramsの内部計算ではrotated_positionが併用される。
      final Sp3dV3D v = i.rotated(this.rotate_axis, this.radian);
      r.add(
          Sp3dV2D(
              origin.x + this.focus_length * (v.x - this.position.x) / (this.position.z - v.z),
              origin.y + this.focus_length * (this.position.y - v.y) / (this.position.z - v.z)
          )
      );
    }
    return r;
  }

  /// (en)Generates and returns an arithmetic data object for drawing.
  /// The return value does not include data that is not drawn.
  ///
  /// (ja)描画用のデータオブジェクトを生成して返します。
  /// 戻り値には描画対象外のデータは含まれません。
  ///
  /// * [world] : The World Obj.
  /// * [origin] : The world origin in canvas.
  ///
  /// Returns calculated data.
  List<Sp3dFaceObj> get_prams(Sp3dWorld world, Sp3dV2D origin) {
    List<Sp3dFaceObj> r = [];
    for(Sp3dObj obj in world.objs) {
      final List<Sp3dV2D> conv2d = this.convert(obj, origin);
      for (Sp3dFragment i in obj.fragments) {
        for (Sp3dFace j in i.faces) {
          final List<Sp3dV3D> v = j.get_vertices(obj);
          final Sp3dV3D n = Sp3dV3D.surface_normal(v).nor();
          final Sp3dV3D c = Sp3dV3D.ave(v);
          // ここでは回転後の値を使う。
          final Sp3dV3D d = (c - this.rotated_position).nor();
          final double cam_theta = Sp3dV3D.dot(n, d);
          // cosΘがマイナスなら、カメラの向きと面の向きが同じなので描画対象外
          if (cam_theta >= 0) {
            r.add(Sp3dFaceObj(
                obj,
                i,
                j,
                v,
                _get2dV(j, conv2d),
                n,
                cam_theta,
                Sp3dV3D.dist(c, this.rotated_position)));
          }
        }
      }
    }
    return r;
  }

  List<Sp3dV2D> _get2dV(Sp3dFace face, List<Sp3dV2D> conv2d){
    List<Sp3dV2D> r = [];
    for(int i in face.vertex_index_list){
      r.add(conv2d[i]);
    }
    return r;
  }

}