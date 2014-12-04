// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';

final vOuterBox = vComponentFactory(OuterBox);
class OuterBox extends Component<DivElement> {
  build() => vRoot(classes: ['outer-box'])(vBox(parent: this));
}

final vInnerBox = vStaticTreeFactory(() => vDiv(classes: ['inner-box'])('x'));

final vBox = vComponentFactory(Box);
class Box extends Component<DivElement> {
  @property OuterBox parent;

  int _outerWidth = 0;
  int _innerWidth = 0;
  VNode _child;
  StreamSubscription _resizeSub;

  build() {
    _child = vInnerBox();

    return vRoot(classes: ['box'])([
      vDiv()('Outer: $_outerWidth'),
      vDiv()('Inner: $_innerWidth'),
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
  build() => vRoot()([
      vOuterBox(),
      vOuterBox(),
      vOuterBox()
  ]);
}

main() {
  injectComponent(new App(), document.body);
}
