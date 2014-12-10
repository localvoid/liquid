// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart' as vdom;

final outerBox = vdom.componentFactory(OuterBox);
class OuterBox extends Component {
  build() => vdom.root(classes: ['outer-box'])(box(parent: this));
}

final innerBox = vdom.staticTreeFactory(() => vdom.div(classes: ['inner-box'])('x'));

final box = vdom.componentFactory(Box);
class Box extends Component {
  @property OuterBox parent = null;

  int _outerWidth = 0;
  int _innerWidth = 0;
  vdom.VNode _child;
  StreamSubscription _resizeSub;

  build() {
    _child = innerBox();

    return vdom.root(classes: ['box'])([
      vdom.div()('Outer: $_outerWidth'),
      vdom.div()('Inner: $_innerWidth'),
      _child
    ]);
  }

  void attached() {
    _resizeSub = window.onResize.listen((_) {
      invalidate();
    });
  }

  void detached() {
    _resizeSub.cancel();
  }

  Future update() {
    return readDOM().then((_) {
      _outerWidth = parent.element.clientWidth;
      _innerWidth = _child.ref.clientWidth;
      return writeDOM().then((_) {
        updateVRoot(build());
      });
    });
  }
}

class App extends Component<DivElement> {
  build() => vdom.root()([
      outerBox(),
      outerBox(),
      outerBox()
  ]);
}

main() {
  injectComponent(new App(), document.body);
}
