// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Abstract base class for all Components
abstract class ComponentBase implements v.Context {
  /// Component is rendered its subtree.
  static const renderedFlag = 1;

  /// Component is attached to the DOM.
  static const attachedFlag = 1 << 1;

  /// Component is dirty and should be updated in the next Update Loop
  static const dirtyFlag    = 1 << 2;

  /// Unique key
  final Object key;

  /// Components should have HtmlElement that it owns, it can be mounted to
  /// an existing element, or create its own.
  final html.Element element;

  /// Component's parent is used to establish parent-child relationship, in our
  /// model parent-child relationship is not exactly the same as in DOM.
  final ComponentBase parent;

  /// Context
  final int depth;

  int flags;

  /// Component is rendered its subtree.
  bool get isRendered => (flags & renderedFlag) == renderedFlag;

  /// Component is attached to the DOM.
  bool get isAttached => (flags & attachedFlag) == attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (flags & dirtyFlag) == dirtyFlag;

  /// [ComponentBase] constructor
  ///
  /// Execution context: [UpdateLoop]:write
  ComponentBase(this.key, this.element, this.parent, this.depth, {this.flags: 0});

  /// Update [Component]'s tag tree.
  void update() {
    flags &= ~dirtyFlag;
  }

  void updateFinish() {
    flags &= ~dirtyFlag;
  }

  /// Invoked when the Component is attached to the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void attached() {
    assert(!isAttached);
    flags |= attachedFlag;
  }

  /// Invoked when the Component is detached from the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void detached() {
    assert(isAttached);
    flags &= ~attachedFlag;
  }

  /// Find html element that is between Component's root element and [e]
  /// that matches [selector].
  ///
  /// TODO: rename?
  html.Element queryMatchingParent(html.Element e, String selector) {
    final sentinel = element.parent;
    do {
      if (e.matches(selector)) {
        return e;
      }
      e = e.parent;
    } while (e != null || identical(e, sentinel));

    return null;
  }
}
