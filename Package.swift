// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "CompositionKit",
  platforms: [.iOS(.v12)],
  products: [
    .library(name: "CompositionKit", targets: ["CompositionKit"]),
    .library(name: "CompositionKitVerge", targets: ["CompositionKitVerge"]),
  ],
  dependencies: [
    .package(url: "https://github.com/muukii/MondrianLayout.git", from: "0.8.0"),
    .package(name: "Verge", url: "https://github.com/VergeGroup/Verge", from: "8.14.0"),
    .package(url: "https://github.com/muukii/Descriptors.git", from: "0.2.1"),
  ],
  targets: [
    .target(
      name: "CompositionKit",
      dependencies: ["MondrianLayout", "Descriptors"]
    ),
    .target(
      name: "CompositionKitVerge",
      dependencies: ["Verge", "CompositionKit"]
    )
  ]
)
