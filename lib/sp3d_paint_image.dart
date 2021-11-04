import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/sp3d_faceobj.dart';

/// (en)This is a conversion class for drawing images used inside Sp3dRenderer.
///
/// (ja)Sp3dRenderer内部で使用する、画像の描画用変換クラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-10-31 20:13:16
///
class Sp3dPaintImage {
  final String class_name = 'Sp3dPaintImage';
  final String version = '1';

  // マテリアルの各種情報。
  final Sp3dMaterial material;

  // 元画像のサイズ
  late Size imageSize;

  // 変換行列の元
  Float64List f64 = Float64List.fromList([
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
  late List<Color> colors;

  // 色情報と頂点のインデックス。
  late List<int> indices;

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
  Future<bool> create_shader(Image image) async {
    try {
      final Float64List mf64 = this.f64.sublist(0);
      this.p.shader =
          ImageShader(image, TileMode.mirror, TileMode.mirror, mf64);
      this.imageSize = Size(image.width.toDouble(), image.height.toDouble());
      this.textureCoordinates = _getTextureCoordinates(this.imageSize);
      this.colors = _getColors();
      this.indices = _getIndices();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// (en)Gets the paint class with the shader set. It can only be called after executing the create_shader function.
  ///
  /// (ja)シェーダーが設定されたペイントクラスを取得します。create_shader functionを実行した後でしか呼び出せません。
  ///
  /// Returns paint class.
  Paint get_paint() {
    return this.p;
  }

  /// (en)Generate vertices for drawing internally. You can draw this return value with canvas.drawVertices.
  /// e.g. canvas.drawVertices(update_vertices(fo), ui.BlendMode.srcOver, this_class.get_paint());
  ///
  /// (ja)描画用のverticesを生成します。戻り値をcanvas.drawVerticesで描画できます。
  ///
  /// * [fo] : face object.
  ///
  /// Returns Vertices of this material.
  Vertices update_vertices(Sp3dFaceObj fo) {
    late List<Offset> verts;
    if(fo.vertices2d.length==4) {
      verts = [
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y),
        Offset(fo.vertices2d[1].x, fo.vertices2d[1].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y),
        Offset(fo.vertices2d[3].x, fo.vertices2d[3].y),
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y)
      ];
    }
    else{
      verts = [
        Offset(fo.vertices2d[0].x, fo.vertices2d[0].y),
        Offset(fo.vertices2d[1].x, fo.vertices2d[1].y),
        Offset(fo.vertices2d[2].x, fo.vertices2d[2].y)
      ];
    }
    final int list_end = fo.vertices2d.length == 4 ? 6 : 3;
    return Vertices(
      VertexMode.triangleStrip,
      verts,
      textureCoordinates: this.textureCoordinates.sublist(0, list_end),
      colors: this.colors.sublist(0, list_end),
      indices: this.indices.sublist(0, list_end),
    );
  }

  /// (en)Set the image cropping information.
  ///
  /// (ja)画像の切り出し情報を設定します。
  List<Offset> _getTextureCoordinates(Size imageSize) {
    return this.material.texture_coordinates!= null ? this.material.texture_coordinates! :
    [
      Offset(0.0, 0.0),
      Offset(0.0, imageSize.height),
      Offset(imageSize.width, imageSize.height),
      Offset(imageSize.width, imageSize.height),
      Offset(imageSize.width, 0.0),
      Offset(0.0, 0.0)
    ];
  }

  /// (en)Generates color information. Black always returns.
  ///
  /// (ja)カラー情報を生成します。常に黒が返ります。
  static List<Color> _getColors() {
    return [
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 0, 0, 0),
    ];
  }

  /// (en)Returns the color and index information of 3D vertices.
  ///
  /// (ja)色、及び3次元頂点のインデックス情報を返します。
  static List<int> _getIndices() {
    return [0, 1, 2, 3, 4, 5];
  }
}
