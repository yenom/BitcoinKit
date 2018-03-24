// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BitcoinKit",
    products: [
        .library(name: "BitcoinKit", targets: ["BitcoinKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/copenssl.git", .exact("1.0.0-rc.1")),
    ],
    targets: [
        .target(
            name: "BitcoinKit",
            dependencies: ["BitcoinKitPrivate"]
        ),
        .target(
            name: "BitcoinKitPrivate"
        ),
        .testTarget(
            name: "BitcoinKitTests",
            dependencies: ["BitcoinKit"]
        )
    ],
    swiftLanguageVersions: [4]
)
