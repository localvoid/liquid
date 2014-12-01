// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class OuterBox extends Component<DivElement> {
  OuterBox(Context context) : super(context);

  build() {
    return vRoot(classes: ['outer-box'])(vBox(parent: this));
  }
}

final vOuterBox = vComponentFactory(OuterBox);

class Box extends Component<DivElement> {
  @property OuterBox parent;

  int _outerWidth = 0;
  int _innerWidth = 0;
  VComponentBase _child;
  StreamSubscription _resizeSub;

  Box(Context context) : super(context);

  build() {
    _child = vInnerBox(0, null);

    return vRoot(classes: ['box'])([
      vdom.div()('Outer: $_outerWidth'),
      vdom.div()('Inner: $_innerWidth'),
      _child
    ]);
  }

  void attached() {
    _resizeSub = window.onResize.listen((_) {
      invalidate();
    });
    super.attached();
  }

  void detached() {
    _resizeSub.cancel();
    super.detached();
  }

  void update() {
    super.update();
    readDOM().then((_) {
      _outerWidth = parent.element.clientWidth;
      _innerWidth = _child.ref.clientWidth;
      writeDOM().then((_) {
        super.update();
      });
    });
  }
}

final vBox = vComponentFactory(Box);

class InnerBox extends Component<DivElement> {
  InnerBox(Context context) : super(context);

  build() {
    return vRoot(classes: ['inner-box'])('x');
  }
}

final vInnerBox = vComponentFactory(InnerBox);

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return vRoot()([vOuterBox(),
                    vOuterBox(),
                    vOuterBox()]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
