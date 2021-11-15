// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ENASecurity",
    platforms: [
      .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ENASecurity",
            targets: ["ENASecurity"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/corona-warn-app/ASN1Decoder", .upToNextMajor(from: "1.8.1")),
        .package(url: "https://github.com/Kitura/Swift-JWT.git", .upToNextMajor(from: "3.6.201"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ENASecurity",
            dependencies: [
                "CryptoSwift",
                "ASN1Decoder",
                .product(name: "SwiftJWT", package: "Swift-JWT")
            ]
        ),
        .testTarget(
            name: "ENASecurityTests",
            dependencies: ["ENASecurity"]
        )
    ]
)
