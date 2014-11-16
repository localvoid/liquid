import 'dart:html';
import 'package:route/client.dart';
import 'package:liquid_web/pages/home.dart' as home;

void main() {
  final homeUrl = new UrlPattern(r'(/|/index.html)');

  final router = new Router()
    ..addHandler(homeUrl, (_) {
      //home.loadLibrary().then((_) {
        home.main();
      //});
    });

  var path = window.location.pathname;
  if (path.startsWith('/liquid')) {
    path = path.substring('/liquid'.length);
  }
  router.handle(path);
}
