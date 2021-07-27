@JS()
library image_blob_reduce;

import 'dart:html';
import 'dart:js';
import 'package:js/js.dart';
import 'package:js/js_util.dart' show promiseToFuture;

@JS()
abstract class Promise<T> {
  external factory Promise(void Function(void Function(T result) resolve, Function reject) executor);
  external Promise then(void Function(T result) onFulfilled, [Function onRejected]);
}

@anonymous
@JS()
class ImageBlobOptions {
  external int get max;
  external set max(int b);
}

@JS('ImageBlobReduce')
class _ImageBlobReduce {
  external _ImageBlobReduce(JsObject options);
  external Blob toBlob(Blob imageBlob, ImageBlobOptions options);
}

class ImageBlobReduce {
  _ImageBlobReduce _imageBlobReduce;
  ImageBlobReduce() {
    _imageBlobReduce = _ImageBlobReduce(JsObject.jsify({}));
  }

  Future<Blob> toBlob(Blob imageBlob, ImageBlobOptions options) {
    return promiseToFuture<Blob>(_imageBlobReduce.toBlob(imageBlob, options));
  }
}
