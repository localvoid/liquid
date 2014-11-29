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
    return new VRootElement([new VBox(0, this)], classes: ['outer-box']);
  }
}

class VOuterBox extends VComponentBase<OuterBox, DivElement> {
  VOuterBox(Object key) : super(key);

  void create(Context context) {
    component = new OuterBox(context);
    ref = component.element;
  }
}

class Box extends Component<DivElement> {
  final OuterBox parent;
  int _state = 0;
  int _outerWidth = 0;
  int _innerWidth = 0;
  VComponentBase _child;
  StreamSubscription _resizeSub;

  Box(Context context, this.parent) : super(context);

  build() {
    _child = new VInnerBox(0);
    if (_state == 0) {
      return new VRootElement([_child], classes: ['box']);
    } else {
      return new VRootElement([vdom.div(10, [vdom.t('Outer: $_outerWidth')]),
                               vdom.div(11, [vdom.t('Inner: $_innerWidth')]),
                               _child],
                              classes: ['box']);
    }
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
      _state = 1;
      writeDOM().then((_) {
        super.update();
      });
    });
  }
}

class VBox extends VComponentBase<Box, DivElement> {
  OuterBox parent;

  VBox(Object key, this.parent) : super(key);

  void create(Context context) {
    component = new Box(context, parent);
    ref = component.element;
  }
}

class InnerBox extends Component<DivElement> {
  InnerBox(Context context) : super(context);

  build() {
    return new VRootElement([vdom.t('x')], classes: ['inner-box']);
  }
}

class VInnerBox extends VComponentBase<InnerBox, DivElement> {
  VInnerBox(Object key) : super(key);

  void create(Context context) {
    component = new InnerBox(context);
    ref = component.element;
  }
}

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return new VRootElement([new VOuterBox(0),
                             new VOuterBox(1),
                             new VOuterBox(2)]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
