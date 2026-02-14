// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LexborBenchmarks",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.0"),
        .package(url: "https://github.com/Rightpoint/BonMot.git", from: "6.1.0"),
        .package(url: "https://github.com/kylehowells/swift-justhtml.git", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "LexborBenchmarks",
            dependencies: [
                .product(name: "HTMLParser", package: "swift-lexbor"),
                .product(name: "CLexbor", package: "swift-lexbor"),
                "SwiftSoup",
                "BonMot",
                .product(name: "justhtml", package: "swift-justhtml"),
            ]
        ),
    ]
)
