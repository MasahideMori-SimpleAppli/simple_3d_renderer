import 'package:simple_3d/simple_3d.dart';
import 'sp3d_faceobj.dart';
import 'sp3d_v2d.dart';

/// (en)It is a camera for shooting Sp3dWorld.
///
/// (ja)Sp3dWorldの撮影用カメラです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 12:05:24
///
class Sp3dCamera {
  static const String className = 'Sp3dCamera';
  static const String version = '11';

  Sp3dV3D position;
  double focusLength;
  late Sp3dV3D rotateAxis;
  double radian;
  bool isAllDrawn;

  // 内部計算でだけ使用する値。移動と回転を分離し、バッファするのに必要。
  late Sp3dV3D rotatedPosition;

  /// Constructor
  /// * [position] : Camera position in the world.
  /// * [focusLength] : Focus length.
  /// * [rotateAxis] : The axis of rotation of this camera. Normalization is required. Default value is (1,0,0).
  /// * [radian] : The rotation angle of this camera. The unit is radians. radian = degree * pi / 180.
  /// * [isAllDrawn] : If True, Draw all objects. If False, the blind spot from the camera will not be drawn.
  Sp3dCamera(this.position, this.focusLength,
      {Sp3dV3D? rotateAxis, this.radian = 0, this.isAllDrawn = false}) {
    this.rotateAxis = rotateAxis ?? Sp3dV3D(1.0, 0.0, 0.0);
    rotate(this.rotateAxis, radian);
  }

  /// deep copy.
  Sp3dCamera deepCopy() {
    return Sp3dCamera(position.deepCopy(), focusLength,
        rotateAxis: rotateAxis.deepCopy(), radian: radian);
  }

  /// Used to save state.
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
  static Sp3dCamera fromDict(Map<String, dynamic> src) {
    return Sp3dCamera(Sp3dV3D.fromDict(src['position']), src['focus_length'],
        rotateAxis: Sp3dV3D.fromDict(src['rotate_axis']),
        radian: src['radian'],
        isAllDrawn:
            src.containsKey('is_all_drawn') ? src['is_all_drawn'] : false);
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
    rotate(rotateAxis, radian);
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
    rotateAxis = norAxis;
    this.radian = radian;
    rotatedPosition = position.rotated(rotateAxis, -1 * radian);
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
      final Sp3dV3D v = i.rotated(rotateAxis, radian);
      final double preCalc = focusLength / (position.z - v.z);
      r.add(Sp3dV2D(origin.x + preCalc * (v.x - position.x),
          origin.y + preCalc * (position.y - v.y)));
    }
    return r;
  }

  /// (en)Generates and returns an arithmetic data object for drawing.
  /// The return value does not include data that is not drawn.
  ///
  /// (ja)描画用のデータオブジェクトを生成して返します。
  /// 戻り値には描画対象外のデータは含まれません。
  ///
  /// * [objs] : The World Obj list.
  /// * [origin] : The world origin in canvas.
  ///
  /// Returns calculated data.
  List<Sp3dFaceObj> getPrams(List<Sp3dObj> objs, Sp3dV2D origin) {
    List<Sp3dFaceObj> r = [];
    for (var i = 0; i < objs.length; i++) {
      final Sp3dObj obj = objs[i];
      final List<Sp3dV2D> conv2d = convert(obj, origin);
      if (obj.drawMode == EnumSp3dDrawMode.rect) {
        // 長方形に近似した結果をFaceとして返す。
        double minX = double.maxFinite;
        double minY = double.maxFinite;
        double maxX = double.minPositive;
        double maxY = double.minPositive;
        for (final j in conv2d) {
          if (minX > j.x) {
            minX = j.x;
          }
          if (minY > j.y) {
            minY = j.y;
          }
          if (maxX < j.x) {
            maxX = j.x;
          }
          if (maxY < j.y) {
            maxY = j.y;
          }
        }
        r.add(Sp3dFaceObj(
            obj,
            i,
            obj.fragments[0],
            0,
            obj.fragments[0].faces[0],
            0,
            obj.vertices,
            [
              Sp3dV2D(minX, minY),
              Sp3dV2D(minX, maxY),
              Sp3dV2D(maxX, maxY),
              Sp3dV2D(maxX, minY)
            ],
            Sp3dV3D(1, 1, 1),
            1,
            100));
      } else {
        for (var j = 0; j < obj.fragments.length; j++) {
          final Sp3dFragment fragment = obj.fragments[j];
          for (var k = 0; k < fragment.faces.length; k++) {
            final Sp3dFace face = fragment.faces[k];
            final List<Sp3dV3D> v = face.getVertices(obj);
            final Sp3dV3D n = Sp3dV3D.surfaceNormal(v).nor();
            final Sp3dV3D c = Sp3dV3D.ave(v);
            // ここでは回転後の値を使う。
            final double camTheta = Sp3dV3D.dot(n, (c - rotatedPosition).nor());
            final List<Sp3dV2D> v2dl = _get2dV(face, conv2d);
            final double dist = Sp3dV3D.dist(c, rotatedPosition);
            if (isAllDrawn) {
              r.add(Sp3dFaceObj(
                  obj, i, fragment, j, face, k, v, v2dl, n, camTheta, dist));
            } else {
              // cosΘがマイナスなら、カメラの向きと面の向きが同じなので描画対象外
              if (camTheta >= 0) {
                r.add(Sp3dFaceObj(
                    obj, i, fragment, j, face, k, v, v2dl, n, camTheta, dist));
              }
            }
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
