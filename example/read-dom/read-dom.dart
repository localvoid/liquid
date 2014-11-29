// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/dynamic.dart';

class OuterBox extends Component<DivElement> {
  OuterBox(Context context) : super(context);

  build() {
    return new VRoot([vBox(0, {#parent: this})], classes: ['outer-box']);
  }
}

final vOuterBox = vComponentFactory(OuterBox);

class Box extends Component<DivElement> {
  @property
  OuterBox parent;

  int _state = 0;
  int _outerWidth = 0;
  int _innerWidth = 0;
  VComponentBase _child;
  StreamSubscription _resizeSub;

  Box(Context context) : super(context);

  build() {
    _child = vInnerBox(0, null);
    if (_state == 0) {
      return new VRoot([_child], classes: ['box']);
    } else {
      return new VRoot([vdom.div(10, [vdom.t('Outer: $_outerWidth')]),
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

final vBox = vComponentFactory(Box);

class InnerBox extends Component<DivElement> {
  InnerBox(Context context) : super(context);

  build() {
    return new VRoot([vdom.t('x')], classes: ['inner-box']);
  }
}

final vInnerBox = vComponentFactory(InnerBox);

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return new VRoot([vOuterBox(0, null),
                      vOuterBox(1, null),
                      vOuterBox(2, null)]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
