part of liquid.example.a;

final outerBox = componentFactory(OuterBox);
class OuterBox extends Component<DivElement> {
  build() => root(classes: ['outer-box'])(box(parent: this));
}

final innerBox = staticTreeFactory(() => div(classes: ['inner-box'])('x'));
