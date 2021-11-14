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
  final String className = 'Sp3dCamera';
  final String version = '4';
  Sp3dV3D position;
  double focusLength;
  late Sp3dV3D rotateAxis;
  double radian;
  // 内部計算でだけ使用する値。移動と回転を分離し、バッファするのに必要。
  late Sp3dV3D rotatedPosition;

  /// Constructor
  /// * [position] : Camera position in the world.
  /// * [focusLength] : Focus length.
  /// * [rotateAxis] : The axis of rotation of this camera. Normalization is required. Default value is (1,0,0).
  /// * [radian] : The rotation angle of this camera. The unit is radians. radian = degree * pi / 180.
  Sp3dCamera(this.position, this.focusLength,
      {Sp3dV3D? rotateAxis, this.radian = 0}) {
    this.rotateAxis = rotateAxis ?? Sp3dV3D(1.0, 0.0, 0.0);
    this.rotate(this.rotateAxis, this.radian);
  }

  Sp3dCamera deepCopy() {
    return Sp3dCamera(this.position.deepCopy(), this.focusLength,
        rotateAxis: this.rotateAxis.deepCopy(), radian: this.radian);
  }

  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = this.className;
    d['version'] = this.version;
    d['position'] = this.position.toDict();
    d['focus_length'] = this.focusLength;
    d['rotate_axis'] = this.rotateAxis.toDict();
    d['radian'] = this.radian;
    return d;
  }

  static Sp3dCamera fromDict(Map<String, dynamic> src) {
    return Sp3dCamera(Sp3dV3D.fromDict(src['position']), src['focus_length'],
        rotateAxis: Sp3dV3D.fromDict(src['rotate_axis']),
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
    this.rotate(this.rotateAxis, this.radian);
    return this;
  }

  /// (en)Rotate this camera.
  ///
  /// (ja)このカメラの向きを変更します。
  ///
  /// * [norAxis] : Camera rotation axis. Normalization is required.
  /// * [radian] : Camera rotation. radian = degree * pi / 180.
  ///
  /// Returns this.
  Sp3dCamera rotate(Sp3dV3D norAxis, double radian) {
    this.rotateAxis = norAxis;
    this.radian = radian;
    this.rotatedPosition = this.position.rotated(this.rotateAxis, -1 * radian);
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
    for (Sp3dV3D i in obj.vertices) {
      // 実質的にはワールド側全体が回転している。このため、get_pramsの内部計算ではrotated_positionが併用される。
      final Sp3dV3D v = i.rotated(this.rotateAxis, this.radian);
      r.add(Sp3dV2D(
          origin.x +
              this.focusLength *
                  (v.x - this.position.x) /
                  (this.position.z - v.z),
          origin.y +
              this.focusLength *
                  (this.position.y - v.y) /
                  (this.position.z - v.z)));
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
  List<Sp3dFaceObj> getPrams(Sp3dWorld world, Sp3dV2D origin) {
    List<Sp3dFaceObj> r = [];
    for (Sp3dObj obj in world.objs) {
      final List<Sp3dV2D> conv2d = this.convert(obj, origin);
      for (Sp3dFragment i in obj.fragments) {
        for (Sp3dFace j in i.faces) {
          final List<Sp3dV3D> v = j.getVertices(obj);
          final Sp3dV3D n = Sp3dV3D.surfaceNormal(v).nor();
          final Sp3dV3D c = Sp3dV3D.ave(v);
          // ここでは回転後の値を使う。
          final Sp3dV3D d = (c - this.rotatedPosition).nor();
          final double camTheta = Sp3dV3D.dot(n, d);
          // cosΘがマイナスなら、カメラの向きと面の向きが同じなので描画対象外
          if (camTheta >= 0) {
            r.add(Sp3dFaceObj(obj, i, j, v, _get2dV(j, conv2d), n, camTheta,
                Sp3dV3D.dist(c, this.rotatedPosition)));
          }
        }
      }
    }
    return r;
  }

  List<Sp3dV2D> _get2dV(Sp3dFace face, List<Sp3dV2D> conv2d) {
    List<Sp3dV2D> r = [];
    for (int i in face.vertexIndexList) {
      r.add(conv2d[i]);
    }
    return r;
  }
}
