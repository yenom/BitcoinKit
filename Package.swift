// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BitcoinKit",
    products: [
        .library(name: "BitcoinKit", targets: ["BitcoinKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/copenssl.git", .exact("1.0.0-rc.1")),
        .package(url: "https://github.com/Boilertalk/secp256k1.swift", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/vapor-community/random.git", .upToNextMinor(from: "1.2.0"))
    ],
    targets: [
        .target(
            name: "BitcoinKit",
            dependencies: ["BitcoinKitPrivate", "secp256k1", "Random"]
        ),
        .target(
            name: "BitcoinKitPrivate",
            dependencies: ["COpenSSL", "secp256k1"]
        ),
        .testTarget(
            name: "BitcoinKitTests",
            dependencies: ["BitcoinKit"]
        )
    ],
    swiftLanguageVersions: [4]
)
