# 0.2.0

- `VComponent` merged into `Component`. If you want to use raw DOM,
  just overload render and update methods. It will be much easier to
  create reusable Components that can work as a virtual dom or raw dom
  container.
- added new Virtual DOM Node `VRootNode` that should be used as a
  root-level element in `Component`s virtual tree.
- `updateSubtree()` replaced with `updateVRoot(VRootNode)`.
- `vdom.Node build()` replaced with `VRootBase build()`.
- `Scheduler` moved to separate package `dom_scheduler`. Global
  instance of the scheduler is available at `scheduler` variable.
- added `insertBefore`, `move`, `removeChild` methods to `Component`
  class, they're called when there are modifications in `VRootNode`
  children list.
- changed semantics of `attached` and `detached`, they're called when
  nodes attached or detached from the attached `Context`. If the item
  is detached, it doesn't mean that its real dom element is detached
  from the document. This way is much better for implementing
  transitions.
- Added `VComponentBase`, `VComponent` and `VComponentContainer`
  abstract virtual dom nodes. `VDomComponent` removed.
- `updateFinish` method removed.
- When `build` method returns `null`, it means that there is no need
  to update using virtual dom.
- Added `VRootDecorator` that can be used to implement Decorator
  components.
- It is no longer required to create html Element in `Component`
  constructors. By default `Component`s will create `DivElement` as a
  root-level element, if you want to override this behavior, just
  override `create` method.
- Added function to create `VComponent` factories:
  `vComponentFactory(Type componentType)`.
- Added `@property` annotation for `Component` properties.