// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SK1Kit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SK1Tokens", targets: ["SK1Tokens"]),
        .library(name: "SK1UI", targets: ["SK1UI"]),
    ],
    targets: [
        .target(name: "SK1Tokens", path: "Sources/SK1Tokens"),
        // SwiftUI components. Every file that imports SwiftUI is wrapped in `#if canImport(SwiftUI)`, so on Linux the
        // module builds with only its Foundation-only text logic (`SK1.Format`), which its tests cover there too.
        .target(name: "SK1UI", dependencies: ["SK1Tokens"], path: "Sources/SK1UI"),
        .testTarget(name: "SK1TokensTests", dependencies: ["SK1Tokens"], path: "Tests/SK1TokensTests"),
        .testTarget(name: "SK1UITests", dependencies: ["SK1UI"], path: "Tests/SK1UITests"),
    ]
)
