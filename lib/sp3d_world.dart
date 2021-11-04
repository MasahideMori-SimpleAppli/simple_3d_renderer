import 'dart:typed_data';
import 'dart:ui';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/sp3d_paint_image.dart';

/// (en)It is a world class for handling multiple Sp3dObj at once.
///
/// (ja)複数のSp3dObjをまとめて扱うためのワールドクラスです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 14:58:34
///
class Sp3dWorld {
  final String class_name = 'Sp3dWorld';
  final String version = '2';
  List<Sp3dObj> objs;

  // コンバートされた各オブジェクトごとの画像情報
  Map<Sp3dObj, Map<int, Image>> converted_images = {};

  // レンダリング情報を構成するためのイメージのMap。構成に失敗したイメージはnullが入る。
  Map<Sp3dMaterial, Sp3dPaintImage?> paint_images = {};

  /// Constructor
  /// * [objs] : World obj.
  Sp3dWorld(this.objs);

  Sp3dWorld deep_copy() {
    return Sp3dWorld(this.objs);
  }

  Map<String, dynamic> to_dict() {
    Map<String, dynamic> d = {};
    d['class_name'] = this.class_name;
    d['version'] = this.version;
    List<Sp3dObj> mobjs = [];
    for (Sp3dObj i in this.objs) {
      mobjs.add(i.deep_copy());
    }
    d['objs'] = mobjs;
    return d;
  }

  static Sp3dWorld from_dict(Map<String, dynamic> src) {
    List<Sp3dObj> mobjs = [];
    for (Map<String, dynamic> i in src['objs']) {
      mobjs.add(Sp3dObj.from_dict(i));
    }
    return Sp3dWorld(mobjs);
  }

  /// (en)Converts Uint8List to an image class and returns it.
  ///
  /// (ja)Uint8Listを画像クラスに変換して返します。
  Future<Image> _bytesToImage(Uint8List bytes) async {
    Codec codec = await instantiateImageCodec(bytes);
    FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  /// (en)Loads and initializes the image file for rendering.
  ///
  /// (ja)レンダリング用の画像ファイルを読み込んで初期化します。
  /// Return : If an error occurs, it returns a list of the objects in which the error occurred.
  /// If normal, an empty array is returned.
  Future<List<Sp3dObj>> init_images() async {
    Map<Sp3dObj, bool> r = {};
    for (Sp3dObj obj in this.objs) {
      for (Sp3dMaterial m in obj.materials) {
        try {
          if (m.image_index != null) {
            Image img = await _bytesToImage(obj.images[m.image_index!]);
            if (this.converted_images.containsKey(obj)) {
              this.converted_images[obj]![m.image_index!] = img;
            } else {
              this.converted_images[obj] = {m.image_index!: img};
            }
            Sp3dPaintImage p_image = Sp3dPaintImage(m);
            p_image.create_shader(img);
            this.paint_images[m] = p_image;
          }
        } catch (e) {
          this.paint_images[m] = null;
          r[obj] = false;
        }
      }
    }
    return r.keys.toList();
  }

  /// (en)Copy the object to the specified coordinates in the world.
  ///
  /// (ja)ワールド内の指定座標にオブジェクトをコピーして設置します。
  ///
  /// * [obj] : target obj.
  /// * [coordinate] : paste position.
  void add(Sp3dObj obj, Sp3dV3D coordinate) {
    this.objs.add(obj.deep_copy().move(coordinate));
  }

  /// (en)Removes the specified object from the world.
  ///
  /// (ja)指定されたオブジェクトをワールドから取り除きます。
  ///
  /// * [obj] : target obj.
  void remove(Sp3dObj obj) {
    this.objs.remove(obj);
  }
}
