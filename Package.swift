// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "stringsutil",
    platforms: [ .macOS(.v13) ],
    products: [
        .executable(name: "stringsutil", targets: [ "stringsutil" ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "stringsutil",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "stringsutilTests",
            dependencies: ["stringsutil"])
    ]
)
