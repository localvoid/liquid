// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/components.dart';

class Item {
  static int __nextId = 0;
  final int id;
  String text;

  Item([this.text = '']) : id = __nextId++;
}

class TodoItem extends VComponent {
  Item item;

  TodoItem(ComponentBase parent, this.item)
      : super('li', parent);

  void updateProperties(Item newItem) {
    if (item.text != newItem.text) {
      item = newItem;
      update();
    }
  }

  build() => vdom.li(0, [vdom.t(item.text)]);

  static VDomInitFunction init(Item item) {
    return (component, context) {
      if (component == null) {
        return new TodoItem(context, item);
      }
      component.updateProperties(item);
    };
  }
}

class TodoList extends VComponent {
  List<Item> items;

  TodoList(ComponentBase parent, this.items)
      : super('ul', parent);

  build() => vdom.ul(0, items.map((i) => component(i.id, TodoItem.init(i))).toList());

  static VDomInitFunction init(List<Item> items) {
    return (component, context) {
      if (component == null) {
        return new TodoList(context, items);
      }
      component.update();
    };
  }
}

class TodoApp extends VComponent {
  final List<Item> items;
  String inputText = '';

  TodoApp(ComponentBase parent, this.items)
      : super('div', parent) {
    _initEventListeners();
  }

  void _initEventListeners() {
    Zone.ROOT.run(() {
      element.onClick.matches('.add-button').listen((e) {
        if (inputText.isNotEmpty) {
          _addItem(inputText);
          inputText = '';
          invalidate();
        }
        e.preventDefault();
        e.stopPropagation();
      });

      element.onChange.matches('input').listen((e) {
        InputElement element = e.matchingTarget;
        inputText = element.value;
        e.stopPropagation();
      });
    });
  }

  void _addItem(String text) {
    items.add(new Item(text));
  }

  build() {
    return vdom.div(0, [
      vdom.h3(0, [vdom.t('TODO')]),
      component(1, TodoList.init(this.items)),
      vdom.form(2, [
        component(0, TextInputComponent.init(value: inputText)),
        vdom.button(1, [vdom.t('Add item')], classes: ['add-button'])
        ])
      ]);
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  root.append(new TodoApp(root, []));
}
