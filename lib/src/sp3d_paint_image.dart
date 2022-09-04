import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:simple_3d/simple_3d.dart';
import 'sp3d_faceobj.dart';

/// (en)This is a conversion class for drawing images used inside Sp3dRenderer.
///
/// (ja)Sp3dRenderer内部で使用する、画像の描画用変換クラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-10-31 20:13:16
///
class Sp3dPaintImage {
  // マテリアルの各種情報。
  final Sp3dMaterial material;

  // 変換行列の元
  static final Float64List _f64 = Float64List.fromList([
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
  ]);

  // 画像の切り出し位置指定
  late List<Offset> textureCoordinates;

  // 色情報。画像の場合は全て黒。
  static const List<Color> _colors = [
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 0, 0, 0),
  ];

  // 色情報と頂点のインデックス。
  static const List<int> _indices = [0, 1, 2, 3, 4, 5];

  Paint p = Paint();

  /// Constructor
  Sp3dPaintImage(this.material);

  /// (en)Load the image and create a shader inside.
  ///
  /// (ja)画像を読み込んで内部にシェーダーを作成します。
  ///
  /// * [image] : Sp3dObj.
  ///
  /// Returns: If success, true.
  Future<bool> createShader(Image image) async {
    try {
      final Float64List mf64 = _f64.sublist(0);
      p.shader = ImageShader(image, TileMode.mirror, TileMode.mirror, mf64);
      textureCoordinates = _getTextureCoordinates(
          image.width.toDouble(), image.height.toDouble());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// (en)Gets the paint class with the shader set. This can only be called after executing the create_shader function.
  ///
  /// (ja)シェーダーが設定されたペイントクラスを取得します。create_shader functionを実行した後でしか呼び出せません。
  ///
  /// Returns paint class.
  Paint getPaint() {
    return p;
  }

  /// (en)Generate vertices for drawing internally. You can draw this return value with canvas.drawVertices.
  /// e.g. canvas.drawVertices(updateVertices(fo), ui.BlendMode.srcOver, this_class.get_paint());
  ///
  /// (ja)描画用のverticesを生成します。戻り値をcanvas.drawVerticesで描画できます。
  ///
  /// * [fo] : face object.
  ///
  /// Returns Vertices of this material.
  Vertices updateVertices(Sp3dFaceObj fo) {
    late List<Offset> verts;
    if (fo.vertices2d.length == 4) {
      verts = [
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y),
        Offset(fo.vertices2d[1].x, fo.vertices2d[1].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y),
        Offset(fo.vertices2d[3].x, fo.vertices2d[3].y),
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y)
      ];
    } else {
      verts = [
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y),
        Offset(fo.vertices2d[1].x, fo.vertices2d[1].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y)
      ];
    }
    final int listEnd = fo.vertices2d.length == 4 ? 6 : 3;
    return Vertices(
      VertexMode.triangleStrip,
      verts,
      textureCoordinates: textureCoordinates.sublist(0, listEnd),
      colors: _colors.sublist(0, listEnd),
      indices: _indices.sublist(0, listEnd),
    );
  }

  /// (en)Set the image cropping information.
  ///
  /// (ja)画像の切り出し情報を設定します。
  List<Offset> _getTextureCoordinates(double width, double height) {
    return material.textureCoordinates != null
        ? material.textureCoordinates!
        : [
            const Offset(0.0, 0.0),
            Offset(0.0, height),
            Offset(width, height),
            Offset(width, height),
            Offset(width, 0.0),
            const Offset(0.0, 0.0)
          ];
  }
}
