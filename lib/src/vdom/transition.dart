part of liquid;

/// Experimental implementation. Proof of concept.
class TransitionGroup {
  void enter(v.Node node) {
    final e = node.ref;
    e.classes.add('enter');
    Scheduler.nextFrame.write(0).then((_) {
        e.classes.remove('enter');
        e.classes.add('enter-active');
        var sub;
        sub = e.onTransitionEnd.listen((_) {
          e.classes.remove('enter-active');
          sub.cancel();
        });
    });
  }

  void leave(v.Node node, v.Context context) {
    final e = node.ref;
    e.classes.add('leave');
    Scheduler.nextFrame.write(0).then((_) {
        e.classes.remove('leave');
        e.classes.add('leave-active');
        var sub;
        sub = e.onTransitionEnd.listen((_) {
          e.classes.remove('leave-active');
          node.dispose(context);
        });
    });
  }
}

///
/// enter -> enter-active
/// leave -> leave-active
/// move -> move-active
///
class TransitionGroupElement extends v.Element {
  TransitionGroup _group;

  TransitionGroupElement(Object key, String tag, List<v.Node> children)
    : super(key, tag, children);

  void render(v.Context context) {
    super.render(context);
    _group = new TransitionGroup();
  }

  void update(TransitionGroupElement other, v.Context context) {
    super.update(other, context);
    other._group = _group;
  }

  void insertBefore(v.Node node, html.Node nextRef, v.Context context) {
    super.insertBefore(node, nextRef, context);
    _group.enter(node);
  }
  //void move(Node node, html.Node nextRef, Context context);
  void removeChild(v.Node node, v.Context context) {
    _group.leave(node, context);
  }
}
