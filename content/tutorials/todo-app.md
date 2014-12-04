+++
date = "2014-12-03T14:56:44+06:00"
title = "Creating a Single Page Todo App with Liquid"
+++

Before starting this tutorial you should be familiar with the
[Dart language](https://www.dartlang.org).

In this tutorial I'll show how to build a simple Todo application with
Liquid library.

The primary goal of the Liquid library is to create general purpose
library for User Interfaces with reusable Components, and it does not
enforce you to make everything reactive, immutable, or stateless, you
are free to choose any way to structure your application.

## Setup

Make sure that you have
[Dart SDK](https://www.dartlang.org/tools/download.html) installed and
running, the minimum version of the SDK is 1.6.

### File Structure

File structure of our application will conform to the
[Pub Package Layout Conventions](https://www.dartlang.org/tools/pub/package-layout.html).

```
.
├── lib
│   ├── src
│   │   ├── models
│   │   │   ├── item.dart
│   │   │   └── item_list.dart
│   │   └── views
│   │       ├── app.dart
│   │       ├── header.dart
│   │       ├── item.dart
│   │       └── item_list.dart
│   ├── models.dart
│   └── views.dart
├── pubspec.yaml
└── web
    ├── index.dart
    └── index.html
```

### Installing Packages

Open `pubspec.yaml` file in the project root
directory and make sure that you have this dependencies:

```
dependencies:
  browser: any
  liquid: any
```

Now run `$ pub get` command from the project's root directory to install all dependencies.

## Data Model

We will start writing our application by defining Data Model.

### Item

Item is an entry in our Todo List. It is quite simple, the only
important thing is that it should have unique key, so we can easily
find it. This key will be used in the Virtual DOM to find which Node
represents this item.

{{% highlight dart %}}
```
class Item {
  static int _nextId = 0; // Used for Auto-Incremental Unique Keys

  final int id;
  String title;

  Item(this.title) : id = _nextId++;
}
```
{{% /highlight %}}

### ItemList

ItemList will contain all entries and will be responsible for all
modifications. It also provides an event stream that emits events when
something is changed.

{{% highlight dart %}}
```
class ItemList {
  // Here we are creating Dart Streams to listen for
  // notifications when something is changed.
  //
  // If you are not familiar with Dart Stream,
  // you can read about them in this articles:
  //
  // https://www.dartlang.org/docs/tutorials/streams/
  // https://www.dartlang.org/articles/creating-streams/

  StreamController _onChangesController = new StreamController();
  Stream get onChanges => _onChangesController.stream;

  List<Item> items = [];

  // Actions:

  /// Create a new Todo Item
  void createItem(String title) {
    if (title.trim().isNotEmpty) {
      items.add(new Item(title));
      _onChangesController.add(null);
    }
  }

  /// Update title property for Todo item
  void updateItemTitle(int id, String newTitle) {
    if (newTitle.trim().isEmpty) {
      items.removeWhere((i) => i.id == id);
    } else {
      final item = items.firstWhere((i) => i.id == id);
      item.title = newTitle;
    }
    _onChangesController.add(null);
  }
}
```
{{% /highlight %}}

## Introduction to Virtual DOM

If you ever worked with the DOM directly, you understand how hard is
to apply modification to the DOM when UI Component goes from one state
to another.
           
There are couple solutions for this problem, and the most popular is
the data-binding, that is used in libraries like Angular.
           
In the Liquid library we are using Virtual DOM with its diff/patch
algorithm to apply changes to the actual DOM. When state is changed,
we just rebuilding the Virtual DOM from the ground up and the
diff/patch takes care of all changes.

[Steven Luscher: Decomplexifying Code with React](http://www.youtube.com/watch?v=rI0GQc__0SM)
is a great explanation of complexity in UI Components.

## Header Element

Now we will create our first Virtual DOM Node for Header.

{{% highlight dart %}}
```
final vHeader = v.staticTreeFactory(() =>
  v.h1(id: 'header')('TODO Application'));
```
{{% /highlight %}}

`staticTreeFactory(buildFunction)` returns factory function that will
generate virtual dom nodes.

All Nodes that accepts children are implementing function call
interface to specify children `Node()(children)`. Children argument
can be a simple String, single Node, or List of Nodes.

## Introduction to Components

Components is just an extension to html Elements, they have an
additional state, slightly more complex lifecycle and can render and
update itself using Virtual DOM.

## Application Component

It is time to build Component for our Application.

{{% highlight dart %}}
```
class App extends Component {
  @property models.ItemList data;

  v.VTextInput _input;
  String _title = '';

  void init() {
    data.onChanges.listen((_) {
      // Invalidate Component when data is changed.
      //
      // When we invalidate Component, it means that it will
      // be updated on the next rendering frame.
      //
      // This way we can update DOM in batches, no need to
      // update it as soon as possible, especially when the
      // state can be changed mutiple times before browser
      // starts to render new frame.
      invalidate();
    });

    // Add Event Listeners using Event-Delegation.
    element.onKeyPress.matches('input').listen((e) {
      if (e.keyCode == KeyCode.ENTER) {
        if (_input.value.isNotEmpty) {
          data.createItem(_input.value);
          _title = '';
        }
        e.stopPropagation();
        e.preventDefault();
      }
    });
  }

  build() {
    // Here we are assigning VTextInput to [_input] property, so we can
    // reference it from the event listeners.
    _input = v.textInput(value: _title);

    return v.root()([
      vHeader(),
      vItemList(data: data),
      _input
    ]);
  }
}
```
{{% /highlight %}}

## ItemList

Item List will be a simple Virtual Dom Tree, no need to create a
stateful Component. But because it can change, we will use
`dynamicTreeFactory`. By default all named arguments have the same
behavior as `@property`. If you want to use immutable data structures,
just prepend `@immutable` annotation before named argument.

{{% highlight dart %}}
```
final vItemList = v.dynamicTreeFactory(({data}) =>
  v.ul()(data.items.map((i) =>
    vItem(key:    i.id,
          data:   data,
          title:  i.title,
          itemId: i.id)).toList()));
```
{{% /highlight %}}

## Item Component

Item will be implemented as a Component because it has internal
state. To create Components inside of VirtualDOM trees we need to
create a factory for this Component with
`componentFactory(Component)` function.

{{% highlight dart %}}
```
final vItem = v.componentFactory(Item);
class Item extends Component {
  @property models.ItemList data;
  @property int itemId;
  @property String title;

  bool _editing = false;
  v.VTextInput _input;

  void create() { element = new LIElement(); }

  void init() {
    element.onDoubleClick.matches('span').listen((e) {
      _editing = true;
      // We can't focus _input Element right now, because it will be created
      // on the next frame. So we can use special [after] Future and wait
      // until next frame is rendered.
      domScheduler.nextFrame.after().then((_) {
        if (_editing) {
          _input.ref.focus();
        }
      });
      invalidate();
      e.stopPropagation();
      e.preventDefault();
    });

    element.onBlur.capture((e) {
      if (_editing) {
        _editing = false;
        data.updateItemTitle(itemId, _input.value);
      }
    });
  }

  build() {
    var children;
    if (_editing) {
      _input = v.textInput(value: title);
      children = [_input];
    } else {
      _input = null;
      children = [v.span()(title)];
    }

    return v.root()(children);
  }
}
```
{{% /highlight %}}

## Inserting Components into the DOM

Now we need to insert Application Component into the DOM, and we have
a special method for this `injectComponent(component, parentElement)`.

{{% highlight dart %}}
```
void main() {
  final data = new models.ItemList();
  injectComponent(new views.App()..data = data, document.body);
}
```
{{% /highlight %}}

## Source Code

Source code is available at
[GitHub repository](https://github.com/localvoid/liquid-tutorial/).
