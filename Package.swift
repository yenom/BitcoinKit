// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BitcoinKit",
    products: [
        .library(name: "BitcoinKit", targets: ["BitcoinKit"])
    ],
    dependencies: [
        //.package(url: "https://github.com/vapor/cmysql.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "BitcoinKit",
            dependencies: ["BitcoinKitPrivate"]
        ),
        .target(
            name: "BitcoinKitPrivate"
        )
    ],
    swiftLanguageVersions: [4]
)
