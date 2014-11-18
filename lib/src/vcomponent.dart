// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Component that builds and updates its subtree using Virtual DOM.
///
/// It implements special method [updateSubtree] that updates the view
/// of the subtree.
///
/// ```
/// class MyComponent extends VComponent {
///   MyComponent(Object key, Context context)
///       : super(key, 'div', context);
///
///   v.Element build() => vdom.div(0, [vdom.t('Hello VComponent')]);
/// }
/// ```
///
/// If you want to read from the dom, just override [update()] method and
/// call [updateFinish()] when you finish updating:
///
/// ```
/// class MyComponent extends VComponent {
///   int _childWidth = 0;
///   ...
///
///   void update() {
///     updateSubtree();
///     readDOM().then((_) {
///       _childWidth = _childElement.ref.width;
///       writeDOM().then((_) {
///         updateSubtree();
///         updateFinish();
///       });
///     });
///   }
/// }
///
/// ```
abstract class VComponent extends Component {
  /// Reference to the top-level Virtual DOM Element.
  v.Node vElement;

  /// Create a new [VComponent]
  ///
  /// It is necessary to specify [tag], so that we can create real
  /// DOM Element as soon as possible and place it as a placeholder
  /// into the DOM.
  ///
  /// This way we can stop at any point in [update()] method and perform
  /// any async operation.
  ///
  /// Execution context: [Scheduler]:write
  VComponent(String tag,
      Context context,
      {int flags: 0})
      : super(html.document.createElement(tag),
          context,
          flags: flags);

  /// Build Virtual DOM tree for the current state of the [VComponent],
  /// it should include the top-level element, that is already created
  /// as a placeholder.
  ///
  /// Execution context: [Scheduler]:write
  v.Node build();

  /// Update Component's subtree
  ///
  /// NOTE: It also updates the top-level element, that is returned by
  /// the [build()] method.
  ///
  /// Better name suggestions for this method?
  ///
  /// Execution context: [Scheduler]:write
  void updateSubtree() {
    final newVElement = build();
    if (vElement == null) {
      newVElement.mount(element, this);
      newVElement.render(this);
    } else {
      vElement.update(newVElement, this);
    }
    vElement = newVElement;
  }

  /// Lifecycle method that is called when [Component] is rendered for
  /// the first time.
  ///
  /// Execution context: [Scheduler]:write
  void render() {
    assert(vElement == null);
    update();
  }

  /// Lifecycle method that is called when [Component] should be updated.
  ///
  /// Execution context: [Scheduler]:write
  void update() {
    updateSubtree();
    updateFinish();
  }

  /// Lifecycle method that is called when [Component] is attached to the
  /// DOM.
  ///
  /// Execution context: [Scheduler]:write
  void attached() {
    if (vElement != null) {
      vElement.attached();
    }
    super.attached();
  }

  /// Lifecycle method that is called when [Component] is detached from the
  /// DOM.
  ///
  /// Execution context: [Scheduler]:write
  void detached() {
    if (vElement != null) {
      vElement.detached();
    }
    super.detached();
  }
}
