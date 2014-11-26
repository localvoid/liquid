// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Component that renders and updates itself using Virtual DOM.
///
/// ```
/// class MyComponent extends VComponent {
///   MyComponent(Object key, Context context)
///       : super(key, new html.DivElement(), context);
///
///   RootElement build() => new RootElement([vdom.t('Hello VComponent')]);
/// }
/// ```
///
/// If you want to read from the DOM, just override [update] method and
/// call [updateFinish] when you finish updating:
///
/// ```
/// class MyComponent extends VComponent {
///   int _childWidth = 0;
///   ...
///
///   void update() {
///     updateVirtual(build());
///     readDOM().then((_) {
///       _childWidth = _childElement.ref.width;
///       writeDOM().then((_) {
///         updateVirtual(build());
///         updateFinish();
///       });
///     });
///   }
/// }
///
/// ```
abstract class VComponent<T extends html.Element> extends Component<T> {
  /// Reference to the root-level Virtual DOM Element.
  VRootElement<T> vRoot;

  html.Node get container => element;

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
  VComponent(T element,
      Context context,
      {int flags: 0})
      : super(element,
          context,
          flags: flags);

  void insertBefore(vdom.Node node, html.Node nextRef) {
    vdom.injectBefore(node, container, nextRef, this);
  }

  void move(vdom.Node node, html.Node nextRef) {
    container.insertBefore(node.ref, nextRef);
  }

  void removeChild(vdom.Node node) {
    node.dispose(this);
  }

  /// Build Virtual DOM for the current state of the [VComponent].
  ///
  /// Execution context: [Scheduler]:write
  VRootElement<T> build();

  /// Update [VComponent] using Virtual DOM.
  ///
  /// Execution context: [Scheduler]:write
  void updateVirtual(VRootElement<T> newVRoot) {
    if (vRoot == null) {
      newVRoot.mount(this);
      newVRoot.render(this);
    } else {
      vRoot.update(newVRoot, this);
    }
    vRoot = newVRoot;
  }

  /// Lifecycle method that is called when [Component] is rendered for
  /// the first time.
  ///
  /// Execution context: [Scheduler]:write
  void render() {
    assert(vRoot == null);
    update();
  }

  /// Lifecycle method that is called when [Component] should be updated.
  ///
  /// Execution context: [Scheduler]:write
  void update() {
    updateVirtual(build());
    updateFinish();
  }

  /// Lifecycle method that is called when [Component] is attached to the
  /// DOM.
  ///
  /// Execution context: [Scheduler]:write
  void attached() {
    if (vRoot != null) {
      vRoot.attached();
    }
    super.attached();
  }

  /// Lifecycle method that is called when [Component] is detached from the
  /// DOM.
  ///
  /// Execution context: [Scheduler]:write
  void detached() {
    if (vRoot != null) {
      vRoot.detached();
    }
    super.detached();
  }
}
