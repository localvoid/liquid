part of liquid.dynamic;

class _Property {
  const _Property();

  bool equal(a, b) => false;
}

class _ImmutableProperty extends _Property {
  const _ImmutableProperty();

  bool equal(a, b) => a == b;
}

const _Property property = const _Property();
const _ImmutableProperty immutable = const _ImmutableProperty();

HashMap<Symbol, _Property> _lookupProperties(Iterable<DeclarationMirror> declarations) {
  final result = new HashMap<Symbol, _Property>();

  for (var d in declarations) {
    _Property propertyType;
    for (var m in d.metadata) {
      if (m.reflectee is _Property) {
        propertyType = m.reflectee;
        break;
      }
    }
    if (propertyType == null) {
      propertyType = const _Property();
    }
    result[d.simpleName] = propertyType;
  }

  return result;
}