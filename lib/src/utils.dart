part of liquid;

int toggleClass(html.Element element, String className, int property) {
  if (property < 0) {
    element.classes.remove(className);
  } else if (property > 0) {
    element.classes.add(className);
  }
  return 0;
}
