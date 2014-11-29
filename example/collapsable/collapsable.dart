// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/vdom.dart' as v;
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/dynamic.dart';

class Collapsable extends Component<DivElement> {
  bool collapsed = false;

  Collapsable(Context context) : super(context) {
    element.onClick.listen((_) {
      collapsed = true;
      invalidate();
    });
  }

  build() {
    final classes = ['collapsable'];
    if (!collapsed) {
      classes.add('collapsable-open');
    } else {
      classes.add('collapsable-close');
    }
    return new VRootDecorator(const [], classes: classes);
  }
}

class VCollapsable extends VComponentContainer<Collapsable, DivElement> {
  VCollapsable(Object key,
      List<v.Node> children,
      {Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
       : super(key, children, attributes, classes, styles);

  void create(Context context) {
    component = new Collapsable(context);
    ref = component.element;
  }
}

class BasicComponent extends Component<ParagraphElement> {
  @property
  int elapsed;

  String get elapsedSeconds => '${(elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(Context context) : super(context);

  void create() {
    element = new ParagraphElement();
  }

  void attached() {
    super.attached();
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() {
    return new VRoot([vdom.t('Liquid has been successfully '
        'running for $elapsedSeconds seconds.')]);
  }
}

final vBasicComponent = vComponentFactory(BasicComponent);

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return new VRoot([new VCollapsable(#collapsable, [vBasicComponent(0, {#elapsed: 0})])]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
