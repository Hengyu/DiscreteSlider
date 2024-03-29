// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "DiscreteSlider",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v16), .visionOS(.v1)],
    products: [.library(name: "DiscreteSlider", targets: ["DiscreteSlider"])],
    targets: [.target(name: "DiscreteSlider")]
)
