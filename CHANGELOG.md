## 6.0.0
* Enhanced user gesture detection. Since the detector in Sp3dRenderer has been replaced with Sp3dGestureDetector, the callback arguments have changed.
* Supports user zoom operation. Added pinch and mouse scroll callbacks to Sp3dRenderer.
* Some Sp3dRenderer parameter names have been shortened.
* allowFullCtrl has been deprecated. This makes it behave like allowFullCtrl=true whenever useUserGesture is true.
* Sp3dV2D has more features than before and now supports some basic calculations.

## 5.0.0
* Refactored the structure for future development.
* Some speedup.
* Fixed a bug that cannot deep copying of worlds.

## 4.0.1
* Fixed reported issue 1, Fixed a bug related to camera movement by user swipe.
* Added rotationSpeed variable to Sp3dRenderer.

## 4.0.0
* Added isAllDrawn flag to Sp3dCamera.

## 3.0.1

* Updates associated with base library updates.
* Fixed so that if the material corresponding to Face is null, the Face will not be drawn.

## 3.0.0

* Starting with this version, you can get the user's touch action on the rendered object.
* Removed deepCopy, toDict and fromDict function in Sp3dRenderer.
* Added allowFullCtrl, allowUserWorldRotation and checkTouchObj flags to Sp3dRenderer.
* Added onPanDownListener, onPanCancelListener, onPanStartListener, onPanUpdateListener and onPanEndListener to Sp3dRenderer.
* Added ValueNotifier to Sp3dRenderer.

## 2.0.2

* Bug fix of Sp3dWorld fromDict function.

## 2.0.1

* Fix README Usage.
* Made minor corrections to the documentation.

## 2.0.0

* Changed class name and class member name to lower camel case.
* Separated the Japanese README file.
* Sp3dWorld's add function no longer internally copies Sp3dObj for efficiency and direct manipulation.
* Added get and removeAt functions to Sp3dWorld.

## 1.0.2

* Update README.

## 1.0.1

* Bug fix of 3 point mesh.

## 1.0.0

* Added support for drawing PNG image files.
* Changes due to base package updates.

## 0.0.4

* Fixed Usage of README.md.

## 0.0.3

* Fixed a bug where the rendering order was not accurate when there were multiple objects in the world.
* Rendering speed has been greatly improved.
* Changed arg of get_params in Sp3dCamera. This is called internally by Sp3dRenderer.
* Updated README.md.

## 0.0.2

* Updated README.md.

## 0.0.1

* Initial release.
