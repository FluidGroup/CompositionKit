# CompositionKit

A collection of components to build composed component

## Requirements

- Swift 5.5
- iOS 12 +
- [MondrianLayout](https://github.com/muukii/MondrianLayout)

## Components (building blocks)

### AnyView

To create an anonymous view with making content

```swift
func makeSomethingView(onTap: @escaping () -> Void) -> UIView {

  let button = UIButton(..., primaryAction: .init { _ in 
    onTap()
  })
  
  return AnyView { view in 
    VStackBlock {
      button
    }
  }
}
```

## License

MIT
