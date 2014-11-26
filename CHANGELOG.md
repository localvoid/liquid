- added new Virtual DOM Node `VRootNode` that should be used as a
  root-level element in `VComponent`s.
- `updateSubtree()` replaced with `updateVirtual(VRootNode)`.
- `vdom.Node build()` replaced with `VRootNode build()`.
- `tag` argument in `VComponent` constructor replaced with `element`
  argument that accepts `html.Element`.
- `Scheduler` moved to separate package `dom_scheduler`. Global
  instance of the scheduler is available at `scheduler` variable.
- added `insertBefore`, `move`, `removeChild` methods to `VComponent`
  class, they're called when there are modifications in `VRootNode`
  children list.
- changed semantics of `attached` and `detached`, they're called when
  nodes attached or detached from the attached `Context`. If the item
  is detached, it doesn't mean that its real dom element is detached
  from the document. This way is much better for implementing
  transitions.