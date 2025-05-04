import 'dart:js_interop';

extension type Telegram(JSObject _) implements JSObject {
  @JS('WebApp')
  external WebApp get webApp;
}

extension type WebApp(JSObject _) implements JSObject {
  external WebAppInitData get initDataUnsafe;
}

extension type WebAppInitData(JSObject _) implements JSObject {
  external WebAppUser? get user;
}

extension type WebAppUser(JSObject _) implements JSObject {
  external JSNumber? get id;
  external JSString? get username;
}

@JS('Telegram')
external Telegram? get telegram;

String? getUsername() {
  return telegram?.webApp.initDataUnsafe.user?.username?.toDart;
}
