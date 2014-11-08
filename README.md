# Liquid

Library to build User Interfaces in Dart.

Documentation is missing right now, but I've created a
[TodoMVC example](https://github.com/localvoid/todomvc-liquid) that is
heavily commented and explains everything that is really important.

Like [VDom](https://github.com/localvoid/vdom) library, the main
source of inspiration is the [React](http://facebook.github.io/react/)
library.

Like React Composite Components, it supports stateful and stateless
Components, ownership, custom events, and even more.

The main difference is that React supports server-side rendering, and
mounting virtual dom on top of existing dom, because of this it is
quite hard for them to solve certain problems, that I don't have to
deal with.

And I've managed to make virtual dom diff/patch algorithm to work
really
fast. [Here](https://localvoid.github.io/vdom-benchmark/components.html)
is the benchmark for Composite Components.

First case of the benchmark is demonstrating switching from one "page"
to another. And the rest is about changes in lists, for example: chat
window with user list or datatable.

## Web-Components

One of the goals for this library was to make it lightweight, and make
sure that it stays lightweight in all browsers that Dart language
supports. So, there won't be any support for Web Components, until all
major browsers start supporting them.
