# Liquid

Library to build User Interfaces in Dart.

Documentation is missing right now, but I've created a
[TodoMVC example](https://github.com/localvoid/todomvc-liquid) that is
heavily commented and explains everything that is really important.

Like [VDom](https://github.com/localvoid/vdom) library, the main
source of inspiration is the [React](http://facebook.github.io/react/)
library. It is implemented in a completely different way, and with a
different semantics, but it solves the same problems.

Like React Composite Components, it supports stateful and stateless
Components, ownership, custom events, and even more.

Our batching algorithm supports proper read/write batching, and not
just write batching.

And it is really FAST!
[Here](localvoid.github.io/vdom-benchmark/components.html) is the
benchmark for Composite Components.

First case of the benchmark is demonstrating switching from one "page"
to another.  And the rest is about changes in lists, for example: chat
window with user list or datatable.