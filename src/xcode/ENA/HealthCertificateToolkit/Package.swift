// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HealthCertificateToolkit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HealthCertificateToolkit",
            targets: ["HealthCertificateToolkit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/unrelentingtech/SwiftCBOR", .upToNextMajor(from: "0.4.3")),
        .package(url: "https://github.com/corona-warn-app/base45-swift", .branch("distribution/swiftpackage")),
        .package(name: "JSONSchema", url: "https://github.com/kylef/JSONSchema.swift", .upToNextMajor(from: "0.6.0")),
        .package(url: "https://github.com/tsolomko/SWCompression.git", .upToNextMajor(from: "4.5.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HealthCertificateToolkit",
            dependencies: ["SwiftCBOR", "base45-swift", "JSONSchema", "SWCompression"],
            resources: [.process("Ressources/CertificateSchema.json")]
        ),
        .testTarget(
            name: "HealthCertificateToolkitTests",
            dependencies: ["HealthCertificateToolkit", "SwiftCBOR", "SWCompression"]
        ),
    ]
)
