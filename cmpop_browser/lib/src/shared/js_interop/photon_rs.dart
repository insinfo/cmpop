@JS()
library photon_rs;

import 'dart:html';
import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:js/js_util.dart' show promiseToFuture;

/// Provides the image's height, width, and contains the image's raw pixels.
/// For use when communicating between JS and WASM, and also natively.
@JS('wasm_bindgen.PhotonImage')
class PhotonImage {
  // @Ignore
  external PhotonImage.fakeConstructor$();
  external void free();

  /// Create a new PhotonImage from a Vec of u8s, which represent raw pixels.
  external factory PhotonImage(Uint8List raw_pixels, num width, num height);

  /// Create a new PhotonImage from a base64 string.
  external static PhotonImage new_from_base64(String base64);

  /// Create a new PhotonImage from a byteslice.
  external static PhotonImage new_from_byteslice(Uint8List vec);

  /// Get the width of the PhotonImage.
  external num get_width();

  /// Get the PhotonImage's pixels as a Vec of u8s.
  external Uint8List get_raw_pixels();

  /// Get the height of the PhotonImage.
  external num get_height();

  /// Convert the PhotonImage to base64.
  external String get_base64();

  /// Convert the PhotonImage's raw pixels to JS-compatible ImageData.
  external ImageData get_image_data();

  /// Convert ImageData to raw pixels, and update the PhotonImage's raw pixels to this.
  external void set_imgdata(ImageData img_data);
}

/// RGB color type.
@JS('wasm_bindgen.Rgb')
class Rgb {
  // @Ignore
  external Rgb.fakeConstructor$();
  external void free();

  /// Create a new RGB struct.
  external factory Rgb(num r, num g, num b);

  /// Set the Red value.
  external void set_red(num r);

  /// Get the Green value.
  external void set_green(num g);

  /// Set the Blue value.
  external void set_blue(num b);

  /// Get the Red value.
  external num get_red();

  /// Get the Green value.
  external num get_green();

  /// Get the Blue value.
  external num get_blue();
}

/// RGBA color type.
@JS('wasm_bindgen.Rgba')
class Rgba {
  // @Ignore
  external Rgba.fakeConstructor$();
  external void free();

  /// Create a new RGBA struct.
  external factory Rgba(num r, num g, num b, num a);

  /// Set the Red value.
  external void set_red(num r);

  /// Get the Green value.
  external void set_green(num g);

  /// Set the Blue value.
  external void set_blue(num b);

  /// Set the alpha value.
  external void set_alpha(num a);

  /// Get the Red value.
  external num get_red();

  /// Get the Green value.
  external num get_green();

  /// Get the Blue value.
  external num get_blue();

  /// Get the alpha value for this color.
  external num get_alpha();
}

// End module wasm_bindgen
/*declare type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;*/
@anonymous
@JS()
abstract class Photon {
  ///
  /// open image from a js Uint8List and resize
  /// @param {Uint8List} bytes
  /// @param {int} nwidth
  /// @param {int} nheight
  /// @param {int} quality
  /// @returns {Uint8Array}
  ///
  external Uint8List resize_image_from_uint8array(Uint8List bytes, int nwidth, int nheight, int quality);
}

@JS('wasm_bindgen')
external dynamic _initPhotonLib(String urlWasmFile);

Future<Photon> initPhotonLib(String urlWasmFile) {
  return promiseToFuture<Photon>(_initPhotonLib(urlWasmFile));
}
