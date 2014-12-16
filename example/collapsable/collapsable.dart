// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart' as vdom;

final collapsable = vdom.componentFactory(Collapsable);
class Collapsable extends Component {
  @property() bool collapsed = false;

  void create() {
    element = new DivElement();
    element.classes.add('collapsable');
    element.onClick.listen((_) {
      collapsed = true;
      invalidate();
    });
  }

  build() =>
      vdom.rootDecorator(classes: collapsed ? ['collapsable-close'] : ['collapsable-open']);
}

final basic = vdom.componentFactory(Basic);
class Basic extends Component {
  @property() int elapsed = 0;

  String get elapsedSeconds => '${(elapsed / 1000).toStringAsFixed(1)}';

  void create() { element = new ParagraphElement(); }

  void attached() {
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() => vdom.root()('Liquid has been successfully running for $elapsedSeconds seconds.');
}

class App extends Component<DivElement> {
  build() {
    return vdom.root()(
        collapsable()(
            basic(elapsed: 0)
        )
    );
  }
}

main() {
  injectComponent(new App(), document.body);
}
