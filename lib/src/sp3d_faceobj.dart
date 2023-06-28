import 'package:simple_3d/simple_3d.dart';
import 'sp3d_v2d.dart';

///
/// (en)An intermediate object for drawing Sp3dFace.
///
/// (ja)Sp3dFaceを描画するための中間オブジェクトです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-10-02 19:57:01
///
class Sp3dFaceObj {
  // The object to which this face belongs.
  final Sp3dObj obj;
  // The object index in the list.
  final int objIndex;
  // This face parent.
  final Sp3dFragment parent;
  // The index of the parent in the obj fragments list.
  final int parentIndex;
  // This face obj.
  final Sp3dFace face;
  // The index of the face in the fragment faces list.
  final int faceIndex;
  // Face vertices in the world.
  final List<Sp3dV3D> vertices3d;
  // Face vertices on display.
  final List<Sp3dV2D> vertices2d;
  // Normalized surface normal vector
  final Sp3dV3D nsn;
  // The orientation between the face and the camera Θ.
  final double camTheta;
  // Distance between the average position of this surface and the camera.
  final double dist;

  Sp3dFaceObj(
    this.obj,
    this.objIndex,
    this.parent,
    this.parentIndex,
    this.face,
    this.faceIndex,
    this.vertices3d,
    this.vertices2d,
    this.nsn,
    this.camTheta,
    this.dist,
  );
}
