// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLReader",
    products: [
        .library(
            name: "XMLReader",
            targets: ["XMLReader"]),
        .executable(
                name: "XMLReaderCmd",
                targets: ["XMLReaderCmd"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "XMLReaderCmd",
            dependencies: ["XMLReader"]),
        .target(
            name: "XMLReader",
            dependencies: []),
        .testTarget(
            name: "XMLReaderTests",
            dependencies: ["XMLReader"])
    ]
)
