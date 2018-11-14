// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-learn",
    products: [
        .executable(name: "GCDLearn", targets: ["GCDLearn"]),
        .executable(name: "NonBlockingFileIO-learn", targets: ["NonBlockingFileIO-learn"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.8.0"),
    ],
    targets: [
        .target(name: "GCDLearn",
            dependencies: []),
        .target(name: "NonBlockingFileIO-learn",
            dependencies: ["NIO", "NIOHTTP1"]),
    ]
)