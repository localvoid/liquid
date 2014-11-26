// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class OuterBox extends Component<DivElement> {
  OuterBox(Context context) : super(new DivElement(), context);

  build() {
    return new VRootElement([Box.virtual(0, this)], classes: ['outer-box']);
  }

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, context) {
      assert(component == null);
      return new OuterBox(context);
    });
  }
}

class Box extends Component<DivElement> {
  final OuterBox parent;
  int _state = 0;
  int _outerWidth = 0;
  int _innerWidth = 0;
  VDomComponent _child;
  StreamSubscription _resizeSub;

  Box(Context context, this.parent) : super(new DivElement(), context);

  build() {
    _child = InnerBox.virtual(0);
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
    updateVirtual(build());
    readDOM().then((_) {
      _outerWidth = parent.element.clientWidth;
      _innerWidth = (_child.ref as Element).clientWidth;
      _state = 1;
      writeDOM().then((_) {
        updateVirtual(build());
        updateFinish();
      });
    });
  }

  static VDomComponent virtual(Object key, OuterBox parent) {
    return new VDomComponent(key, (component, context) {
      assert(component == null);
      return new Box(context, parent);
    });
  }
}

class InnerBox extends Component<DivElement> {
  InnerBox(Context context) : super(new DivElement(), context);

  build() {
    return new VRootElement([vdom.t('x')], classes: ['inner-box']);
  }

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new InnerBox(context);
      }
    });
  }
}

class App extends Component<DivElement> {
  App(Context context) : super(new DivElement(), context);

  build() {
    return new VRootElement([OuterBox.virtual(0),
                             OuterBox.virtual(1),
                             OuterBox.virtual(2)]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
