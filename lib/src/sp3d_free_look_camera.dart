import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

/// (en)This is a so-called free-look camera,
/// which allows you to freely set the camera position and direction.
///
/// (ja)カメラの位置と向きを自由に設定可能な、いわゆるフリールックカメラです。
class Sp3dFreeLookCamera extends Sp3dCamera {
  // カメラのローカル座標系の方向ベクトル
  Sp3dV3D forward; // 前方方向（カメラが見ている方向）
  Sp3dV3D up; // 上方方向
  Sp3dV3D right; // 右方向。この変数は左手系と右手系のシステムで計算が異なり、常に計算で算出するので保存しない。

  /// Constructor
  /// * [position] : Camera position in the world.
  /// * [focusLength] : Focus length.
  /// * [forward] : Camera forward direction (default is negative Z direction)
  /// * [up] : Upward direction of the camera (default is Y positive direction)
  /// * [rotateAxis] : Not used in this camera.
  /// * [radian] : Not used in this camera.
  /// * [isAllDrawn] : If True, Draw all objects.
  /// If False, the blind spot from the camera will not be drawn.
  Sp3dFreeLookCamera(super.position, super.focusLength,
      {Sp3dV3D? forward,
      Sp3dV3D? up,
      super.rotateAxis,
      super.radian,
      super.isAllDrawn})
      : forward = forward ?? Sp3dV3D(0, 0, -1).nor(),
        up = up ?? Sp3dV3D(0, 1, 0).nor(),
        right = Sp3dV3D(0, 0, 0) {
    rotatedPosition = position;
    // rightベクトルを計算してローカル座標系を初期化
    updateOrientation();
  }

  /// (em) If you call this after updating forward and up,
  /// it will automatically calculate right and
  /// update the camera's local coordinate system.
  ///
  /// (ja) forwardとupの更新後にこれを呼びだすと、
  /// rightを自動計算してカメラのローカル座標系を更新します。
  void updateOrientation() {
    right = Sp3dV3D.cross(forward, up).nor(); // forwardとupの外積でrightを計算
    up = Sp3dV3D.cross(right, forward).nor(); // upを再調整して直交性を確保
    forward = forward.nor(); // forwardを正規化
  }

  @override
  Sp3dFreeLookCamera deepCopy() {
    return Sp3dFreeLookCamera(
      position.deepCopy(),
      focusLength,
      forward: forward.deepCopy(),
      up: up.deepCopy(),
      rotateAxis: rotateAxis.deepCopy(),
      radian: radian,
      isAllDrawn: isAllDrawn,
    );
  }

  @override
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = super.toDict();
    d['forward'] = forward.toDict();
    d['up'] = up.toDict();
    return d;
  }

  /// Used to restore state.
  static Sp3dFreeLookCamera fromDict(Map<String, dynamic> src) {
    return Sp3dFreeLookCamera(
      Sp3dV3D.fromDict(src['position']),
      src['focus_length'],
      forward: Sp3dV3D.fromDict(src['forward']),
      up: Sp3dV3D.fromDict(src['up']),
      rotateAxis: Sp3dV3D.fromDict(src['rotate_axis']),
      radian: src['radian'],
      isAllDrawn: src.containsKey('is_all_drawn') ? src['is_all_drawn'] : false,
    );
  }

  @override
  Sp3dFreeLookCamera move(Sp3dV3D position) {
    this.position = position;
    return this;
  }

  @override
  Sp3dFreeLookCamera rotate(Sp3dV3D norAxis, double radian) {
    rotateAxis = norAxis;
    this.radian = radian;
    position = position.rotated(rotateAxis, -1 * radian);
    return this;
  }

  /// (en) Rotates the direction the camera is facing.
  /// If you are also using the default Sp3dCameraRotationController,
  /// you will also need to change lookAtTarget param in
  /// Sp3dCameraRotationController.
  ///
  /// (ja) カメラの向いている方向を回転します。
  /// デフォルトのSp3dCameraRotationControllerを併用している場合、
  /// Sp3dCameraRotationControllerのlookAtTarget変数も変更する必要があります。
  ///
  /// * [norAxis] : Camera rotation axis. Normalization is required.
  /// * [radian] : Camera rotation. radian = degree * pi / 180.
  Sp3dFreeLookCamera directionRotate(Sp3dV3D norAxis, double radian) {
    // ローカル座標系のベクトルを回転
    forward = forward.rotated(norAxis, radian).nor();
    up = up.rotated(norAxis, radian).nor();
    updateOrientation(); // rightを再計算して直交性を保つ
    return this;
  }

  /// (en) Aims the camera at the specified target.
  ///
  /// (ja) カメラを指定したターゲットに向けます。
  ///
  /// * [target] : Target object center.
  /// * [up] : Upward camera angle (optional, defaults to using auto calculated up)
  void lookAt(Sp3dV3D target, {Sp3dV3D? up}) {
    // 新しいforward方向を計算
    forward = (target - position).nor();
    // upが指定されている場合はそれを使用し、なければ現在のupを維持
    this.up = up != null ? up.nor() : this.up;
    // まず現在のupと新しいforwardからrightを計算
    right = Sp3dV3D.cross(forward, this.up).nor();
    // rightがゼロベクトルでないか確認（forwardとupが平行でない場合）
    if (right.len() > 0.0001) {
      // 微小な閾値でチェック
      // rightとforwardから新しいupを計算
      this.up = Sp3dV3D.cross(right, forward).nor();
    } else {
      // forwardとupが平行な場合、代替のupを生成（ワールドY軸）
      this.up = Sp3dV3D.cross(Sp3dV3D(0, 1, 0), forward).nor();
      if (this.up.len() < 0.0001) {
        // Y軸とも平行ならZ軸
        this.up = Sp3dV3D.cross(Sp3dV3D(0, 0, 1), forward).nor();
      }
      right = Sp3dV3D.cross(forward, this.up).nor();
    }
    // 念の為forwardを再度正規化。
    forward = forward.nor();
  }

  /// (en) Sets the camera direction.
  /// If you do not specify a variable, the existing one will be used.
  ///
  /// (ja) カメラの向きを設定します。
  /// 指定しなかった変数は既存のものが利用されます。
  ///
  /// * [forward] : Camera forward direction.
  /// * [up] : Upward direction of the camera.
  void setOrientation({Sp3dV3D? forward, Sp3dV3D? up}) {
    if (forward != null) {
      this.forward = forward.nor();
    }
    if (up != null) {
      this.up = up.nor();
    }
    updateOrientation();
  }

  @override
  List<Sp3dV2D> convert(Sp3dObj obj, Sp3dV2D origin) {
    List<Sp3dV2D> r = [];
    for (Sp3dV3D i in obj.vertices) {
      // カメラのローカル座標系に基づく変換を考慮
      Sp3dV3D relativePos = i - position;
      // 前方方向への投影
      double zDepth = Sp3dV3D.dot(relativePos, forward);
      if (zDepth > 0) {
        // カメラの前方にある場合のみ描画
        double preCalc = focusLength / zDepth;
        double xProj = Sp3dV3D.dot(relativePos, right);
        double yProj = Sp3dV3D.dot(relativePos, up);
        // Y軸は画面上では逆になる
        r.add(Sp3dV2D(
          origin.x + preCalc * xProj,
          origin.y - preCalc * yProj,
        ));
      } else {
        // カメラ後方は無効値にする（描画対象外の点になる）
        r.add(const Sp3dV2D(double.nan, double.nan));
      }
    }
    return r;
  }

  @override
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
            // ノーマルのカメラと異なり、現在のpositionで計算する。
            final double camTheta = Sp3dV3D.dot(n, (c - position).nor());
            final List<Sp3dV2D> v2dl = get2dV(face, conv2d);
            final double dist = Sp3dV3D.dist(c, position);
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
}
