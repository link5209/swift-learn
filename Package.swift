// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-learn",
    products: [
        .executable(name: "GCDLearn", targets: ["GCDLearn"]),
    ],
    dependencies: [
        // .package(url: "https://github.com/apple/swift-nio-zlib-support.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "GCDLearn",
            dependencies: []),
    ]
)