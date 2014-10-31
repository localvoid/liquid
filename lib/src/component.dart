// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Base class for creating Liquid Components
///
/// lifecycle methods:
///
/// - Constructor: Component should create its own html Element
/// - attached(): Component is attached to the Document
/// - detached(): Component is detached from the Document
/// - render(): Initial render of Components subtree
/// - update(): Update Components subtree to match the current state
/// - dispose(): Destroy Component (it is necessary because we don't have
///   weak pointers, and we need to propagate attached/detached, possible
///   fix: document.registerElement. It is also useful for some old-school
///   optimizations in raw dom components)
///
/// I think that it is enough to create a high-level APIs on top of that,
/// for example Polymer lifecycle:
///
/// - created(): invoked from Constructor
/// - ready(): invoked from Constructor
/// - attached(): attached()
/// - domReady(): invoked from render()
/// - detached(): detached()
/// - attributeChanged(): just some notifications
///
abstract class Component extends ComponentBase {
  html.Element element;

  /// Each Component is responsible in creating of its own html Element.
  ///
  /// MainLoop state: DomWrite
  Component(ComponentBase parent,
      this.element,
      {Object key: null,
       Symbol className: null,
       int flags: 0})
      : super(parent: parent, key: key, className: className, depth: parent.depth + 1, flags: flags) {

    assert(parent != null);
    parent._addChild(this);
  }

  /// Mark Component as a dirty.
  ///
  /// To implement data-binding, do not process incoming events immediately,
  /// add events to some queue or better compose them into one event with the
  /// latest state, and use this method to mark it as a dirty.
  ///
  /// Later in the update() method update DOM with the new state.
  ///
  /// MainLoop state: any
  void invalidate() {
    assert(element != null);

    if (!isDirty) {
      _flags &= ~ComponentBase.cleanFlag;
      UpdateLoop.write(depth, update);
    }
  }

  /// Emit event to parent
  void emit(ComponentEvent e) {
    parent.onEvent(e);
  }
}
