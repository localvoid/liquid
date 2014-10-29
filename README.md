# Liquid Components

Experimental implementation of something similar to React's
[Composite Components](http://facebook.github.io/react/docs/multiple-components.html)

It is build in a way that it can be easily modified to support all
different paradigms for view rendering and mixing them all together:

- raw DOM [Component]
- virtual DOM [VComponent + VComponentElement]
- templates+databinding

## API

```
Top-Level API:

React.createClass => MyComponent extends VComponent (MyComponent.virtual to instantiate virtual element)
React.renderComponent => html.append() + component.attached();
React.unmountComponentAtNode => missing
React.renderComponentToString => missing
React.renderComponentToStaticMarkup => missing
React.isValidClass => `instance is VComponent` ?
React.isValidComponent => `instance is Component` ?
React.DOM => VDom
React.PropTypes => missing
React.initializeTouchEvents => ?
React.children => Component.children (should return List interface)

Component API:

setState => Dart setters => Component.invalidate
replaceState => same as above
forceUpdate => ~Component.invalidate
getDOMNode => Component.element
isMounted => Component.isAttached
transferPropsTo => missing
setProps => use declarative style to pass properties
replaceProps => use declarative style to pass properties
render => VComponent.build
getInitialState => simple constructor
getDefaultProps => simple constructor
propTypes => missing
displayName => Component.toString
componentWillMount => missing
componentDidMount => Component.attached
componentWillReceiveProps => Component.updateProperties
shouldComponentUpdate => isDirty
componentWillUpdate => Component.update
componentDidUpdate => Component.update
componentWillUnmount => ~Component.detached (note: detached is called after element is removed from dom)
```