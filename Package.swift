// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-lexbor",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "HTMLParser",
            targets: ["HTMLParser"]
        ),
        .library(
            name: "CLexbor",
            targets: ["CLexbor"]
        ),
    ],
    targets: [
        .target(
            name: "CLexbor",
            path: "Sources/CLexbor",
            publicHeadersPath: ".",
            cSettings: [
                .define("LEXBOR_STATIC"),
            ]
        ),
        .target(
            name: "HTMLParser",
            dependencies: ["CLexbor"]
        ),
        .testTarget(
            name: "HTMLParserTests",
            dependencies: ["HTMLParser"]
        ),
    ]
)
