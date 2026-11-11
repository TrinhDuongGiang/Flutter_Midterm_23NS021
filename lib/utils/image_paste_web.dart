
import 'dart:js_interop';

@JS('registerImagePaste')
external void _registerImagePaste(JSFunction callback);

@JS('unregisterImagePaste')
external void _unregisterImagePaste();

void registerImagePaste(void Function(String) onPaste) {
  _registerImagePaste(
    ((JSString dataUrl) {
      onPaste(dataUrl.toDart);
    }).toJS,
  );
}

void unregisterImagePaste() {
  _unregisterImagePaste();
}
