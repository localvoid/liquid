import 'dart:html';
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart';
import 'a.dart';

class App extends Component<DivElement> {
  build() => root()([
      outerBox(),
      outerBox(),
      outerBox()
  ]);
}

main() {
  injectComponent(new App(), document.body);
}
