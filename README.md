# Liquid

Library to build User Interfaces in Dart with
[Virtual DOM](https://github.com/localvoid/vdom).

## Installation

Requirements:

 - Dart SDK 1.8 or greater

#### 1. Create a new Dart Web Project
#### 2. Add Liquid library and transformer in `pubspec.yaml` file:

```yaml
dependencies:
  liquid: any
transformers:
- liquid
```

#### 3. Install it

```sh
$ pub get
```

And now you are ready to use it, just import
`'package:liquid/liquid.dart'` and start writing your first
application with Liquid library

## Examples

Here are simple examples that is build with Liquid library:

- [Hello](https://github.com/localvoid/liquid/tree/master/example/hello)
- [Timer](https://github.com/localvoid/liquid/tree/master/example/basic)
- [100 Animated Boxes](https://github.com/localvoid/liquid/tree/master/example/anim-100)
- [Todo App](https://github.com/localvoid/liquid/tree/master/example/todo)
- [Read DOM](https://github.com/localvoid/liquid/tree/master/example/read-dom)
- [Form](https://github.com/localvoid/liquid/tree/master/example/form)

### TodoMVC example

[TodoMVC](http://todomvc.com/) application
[[Source Code](https://github.com/localvoid/todomvc-liquid)], it is
heavily commented and demonstrates many important features of this
library.

### DBMonster Benchmark

[Run](http://localvoid.github.io/liquid-dbmonster/)