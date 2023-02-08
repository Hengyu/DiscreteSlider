// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "DiscreteSlider",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [.library(name: "DiscreteSlider", targets: ["DiscreteSlider"])],
    targets: [.target(name: "DiscreteSlider")]
)
