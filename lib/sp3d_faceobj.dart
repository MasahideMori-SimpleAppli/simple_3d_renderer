import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/sp3d_v2d.dart';

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

  final Sp3dObj obj;
  final Sp3dFragment parent;
  final Sp3dFace face;
  final List<Sp3dV3D> vertices3d;
  final List<Sp3dV2D> vertices2d;
  // normalized surface normal vector
  final Sp3dV3D nsn;
  // The orientation between the face and the camera Θ.
  final double camTheta;
  final double dist;

  Sp3dFaceObj(this.obj, this.parent, this.face, this.vertices3d, this.vertices2d, this.nsn, this.camTheta, this.dist);

}