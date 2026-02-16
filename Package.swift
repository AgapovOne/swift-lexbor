// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-lexbor",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "SwiftLexbor",
            targets: ["SwiftLexbor"]
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
            name: "SwiftLexbor",
            dependencies: ["CLexbor"]
        ),
        .testTarget(
            name: "SwiftLexborTests",
            dependencies: ["SwiftLexbor"]
        ),
    ]
)
