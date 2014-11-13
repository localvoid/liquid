# Liquid

Library to build User Interfaces in Dart with
[Virtual DOM](https://github.com/localvoid/vdom).

Before you start to use this library, it is quite important to
understand [what is Virtual DOM](https://github.com/localvoid/vdom),
and what problems it solves.

This library implements several useful tools that will help you build
applications with Virtual DOM, such as Scheduler, Components, Basic
Form Elements, etc.

## Details

### Scheduler

In order to implement optimal read/write batching we are using the
idea of different execution contexts. All tasks that are used to read
or write DOM should be executed in Scheduler
[Zone](https://www.dartlang.org/articles/zones/). Everything else, like
event listeners should be executed outside of Scheduler zone.

Scheduler provides interface to add write/read tasks to the current
frame, or the next frame. Next frame is used if you want to add some
task from the outside of Scheduler execution context, it is also
useful to implement transitions/animations.

### Extended VDom Context

We are extending default VDom Context and using it to store depth of
the Nodes relative to other Contexts. Depth is used in Scheduler as a
way to prioritize write tasks, so if the parent element removes
invalidated child, there is no need to execute write tasks for this
removed child.

### Component

Component is a Virtual DOM Node, that is responsible for
rendering/updating its subtree.

## Notes

### Web-Components

One of the goals for this library was to make it lightweight, and make
sure that it stays lightweight in all browsers that Dart language
supports. So, there won't be any support for Web Components, until all
major browsers start supporting them.
