part of liquid;

void injectComponent(Component component, html.Element parent) {
  Scheduler.zone.run(() {
    parent.append(component.element);
    component.attached();
    component.update();
  });
}