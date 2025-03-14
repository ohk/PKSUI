// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PKSUI",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PKSUI",
            targets: ["PKSUI"]
        )
    ],
    targets: [        
        .target(name: "PKSUI"),
        .testTarget(
            name: "PKSUITests",
            dependencies: ["PKSUI"]
        ),
    ]
)
