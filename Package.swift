// swift-tools-version:5.4
import PackageDescription

let package = Package(
  name: "CompositionKit",
  platforms: [.iOS(.v12)],
  products: [
    .library(name: "CompositionKit", targets: ["CompositionKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/muukii/MondrianLayout.git", from: "0.5.0")
  ],
  targets: [
    .target(
      name: "CompositionKit",
      dependencies: ["MondrianLayout"],
      path: "CompositionKit"
    )
  ]
)
