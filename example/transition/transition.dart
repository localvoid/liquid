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

  TodoItem(Object key, Component parent, this.item)
      : super(key, 'li', parent);

  void updateProperties(Item newItem) {
    if (item.text != newItem.text) {
      item = newItem;
      update();
    }
  }

  build() => vdom.li(0, [vdom.text(0, item.text + ' '),
                         vdom.button(1, [vdom.t('x')], classes: const ['remove-button'])],
                        attributes: {'key': key.toString()});

  static VDomInitFunction init(Item item) {
    return (component, key, context) {
      if (component == null) {
        return new TodoItem(key, context, item);
      }
      component.updateProperties(item);
    };
  }
}

class TodoList extends VComponent {
  List<Item> items;

  TodoList(Object key, Component parent, this.items)
      : super(key, 'ul', parent);

  build() => new TransitionGroupElement(0, 'ul',
      items.map((i) => component(i.id, TodoItem.init(i))).toList());

  static VDomInitFunction init(List<Item> items) {
    return (component, key, context) {
      if (component == null) {
        return new TodoList(key, context, items);
      }
      component.update();
    };
  }
}

class TodoApp extends VComponent {
  final List<Item> items;
  String inputText = '';

  TodoApp(Object key, Component parent, this.items)
      : super(key, 'div', parent) {
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

      element.onClick.matches('.remove-button').listen((e) {
        final li = queryMatchingParent(e.target, 'li');
        items.removeWhere((i) => i.id == int.parse(li.attributes['key']));
        invalidate();
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
        new TextInput(0, value: inputText),
        vdom.button(1, [vdom.t('Add item')], classes: ['add-button'])
        ])
      ]);
  }
}

main() {
  injectComponent(new TodoApp(0, Component.ROOT, []), document.body);
}
