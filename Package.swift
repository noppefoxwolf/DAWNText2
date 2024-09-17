// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DAWNText2",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DAWNText2",
            targets: ["DAWNText2"]),
    ],
    targets: [
        .target(
            name: "DAWNText2"),
        .testTarget(
            name: "DAWNText2Tests",
            dependencies: ["DAWNText2"]),
    ]
)
