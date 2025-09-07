# CanvasKit

Low-level Image Processing using Metal

## Image Processing

Let's start by defining a context, and a canvas.

The context holds all the information for computation, and computations are done lazily and in batch to ensure performance. Context comes with synchronization point built-in or executed manually.

The canvas hosts all layers, and provides a coordinate space.

```swift
let context = MetalContext()
let canvas = Canvas()
```

Then, we can quickly draw our favorite symbol on a `Layer`.

```swift
let focusRect = CGRect(x: 333, y: 376, width: 359, height: 359)
let configuration = NSImage.SymbolConfiguration(pointSize: 359, weight: .regular, scale: .large)
let image = NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!.withSymbolConfiguration(configuration)!.cgImage!
var focusLayer = try await Layer(image, context: context)
```

Let's remove all margins of the symbol.

```swift
let mask = focusLayer.select() // The mask selecting the visible region of `focusLayer`
let boundary = mask.boundary() // The bounding box of the mask
focusLayer = try await focusLayer.cropping(to: boundary)
```

Then, we can resize the layer, and ensure it sits in our canvas nicely.

```swift
focusLayer = try await focusLayer.aspectRatioResize(.fit, in: focusRect)
```

Let's fill the visible region by our favorite color, and add it to our canvas.

``` swift
let focusSelection = try await focusLayer.select()
try await focusLayer.fill(.init(red: 94 / 255, green: 168 / 255, blue: 224 / 255, alpha: 1), selection: focusSelection)
canvas.add(layer: focusLayer)
```

We can also give the symbol a shadow. Let's start by defining the shadow layer. In the coordinate space of `CanvasKit`, the origin lies on the top-left corner.

```swift
var shadow = Layer(frame: CGRect(center: focusLayer.frame.center, size: CGSize(width: 400, height: 400)), context: context)
shadow.origin -= CGPoint(x: 0, y: 0.5)
```

Let's give the shadow some color.

```swift
try await shadow.fill(PartialColor(red: 1, green: 1, blue: 1, alpha: 43 / 255))
try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: shadow.size)).invert())
```

A small matrix convolution to give it a bit of blur.

```swift
shadow = try await shadow.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 27, distribution: 21), components: .alpha)
try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: CGSize(width: 400, height: 400))))
canvas.add(layer: shadow)
```

Finally, we can render the canvas.

```swift
let layer = try await canvas.makeLayer(width: 1024, height: 1024, context: context)
return try await layer.render()
```
<p align="center">
  <img width="256" height="256" alt="advanced_blend_2" src="https://github.com/user-attachments/assets/15d6b886-fcc7-41d2-b5e6-521909a04f13"/>
</p>

