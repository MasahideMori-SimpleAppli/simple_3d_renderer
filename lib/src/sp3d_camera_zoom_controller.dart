import 'package:flutter/material.dart';
import 'sp3d_camera.dart';

///
/// (en)Class for adjusting camera zoom.
/// Creating a subclass and giving it to Sp3dRenderer allows complex camera control.
///
/// (ja)カメラのズームを調整するためのクラスです。
/// サブクラスを作ってSp3dRendererに与えることで複雑なカメラコントロールが可能になります。
///
/// Author Masahide Mori
///
/// First edition creation date 2022-09-20 21:22:29
///
@immutable
class Sp3dCameraZoomController {
  /// Constructor
  const Sp3dCameraZoomController();

  /// (en)A method that gives the updated zoom value to the camera.
  /// By providing a subclass that overrides this method,
  /// you can control the zoom of the camera in detail.
  /// If you want non-linear zoom speed control,
  /// update the value appropriately according to the current focus value.
  ///
  /// (ja)カメラを受け取り、更新されたズーム値を与えるメソッドです。
  /// このメソッドをオーバーライドしたサブクラスを与えることで、
  /// カメラのズームを詳細にコントロールできます。
  /// 非線形のズームスピードコントロールを行いたい場合は、
  /// 現在のフォーカス値に応じて適切に値を更新してください。
  ///
  /// * [camera] : The camera object.
  /// * [zoomV] : The zoom value.
  /// * [isMouse] : If this action is mouse scroll, this is true.
  void apply(Sp3dCamera camera, double zoomV, bool isMouse) {
    camera.focusLength = camera.focusLength + zoomV;
    // Negative values are not allowed as they invert the calculation.
    if (camera.focusLength < 0) {
      camera.focusLength = 1;
    }
  }
}
