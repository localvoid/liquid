// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Component that builds and updates its subtree with Virtual DOM.
abstract class VComponent extends Component {
  v.Element _vElement;

  VComponent(Object key, String tagName, ComponentBase parent, {int flags: 0})
      : super(key, html.document.createElement(tagName), parent, flags: flags);

  /// Returns virtual tree for the current state
  v.Element build();

  /// Update Subtree
  void updateSubtree() {
    final newVElement = build();
    if (isRendered) {
      _vElement.update(newVElement, this);
    } else {
      newVElement.mount(element, this);
      newVElement.render(this);
      flags |= ComponentBase.renderedFlag;
    }
    _vElement = newVElement;
  }

  void update() {
    updateSubtree();
    updateFinish();
  }

  void attached() {
    if (_vElement != null) {
      _vElement.attached();
    }
    super.attached();
  }

  void detached() {
    if (_vElement != null) {
      _vElement.detached();
    }
    super.detached();
  }
}
