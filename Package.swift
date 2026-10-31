// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SK1Kit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SK1Tokens", targets: ["SK1Tokens"]),
    ],
    targets: [
        .target(name: "SK1Tokens", path: "Sources/SK1Tokens"),
        .testTarget(name: "SK1TokensTests", dependencies: ["SK1Tokens"], path: "Tests/SK1TokensTests"),
    ]
)
