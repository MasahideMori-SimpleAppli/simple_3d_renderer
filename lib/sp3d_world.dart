import 'package:simple_3d/simple_3d.dart';

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
  final String version = '1';
  List<Sp3dObj> objs;

  /// Constructor
  /// * [objs] : World obj.
  Sp3dWorld(this.objs);

  Sp3dWorld deep_copy(){
    return Sp3dWorld(this.objs);
  }

  Map<String, dynamic> to_dict(){
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

  static Sp3dWorld from_dict(Map<String, dynamic> src){
    List<Sp3dObj> mobjs = [];
    for (Map<String, dynamic> i in src['objs']) {
      mobjs.add(Sp3dObj.from_dict(i));
    }
    return Sp3dWorld(mobjs);
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