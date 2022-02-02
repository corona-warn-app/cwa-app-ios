// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HealthCertificateToolkit",
    platforms: [
      .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HealthCertificateToolkit",
            targets: ["HealthCertificateToolkit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/unrelentingtech/SwiftCBOR", .upToNextMajor(from: "0.4.4")),
        .package(url: "https://github.com/corona-warn-app/base45-swift", .branch("distribution/swiftpackage")),
        .package(name: "JSONSchema", url: "https://github.com/eu-digital-green-certificates/JSONSchema.swift", .revision("addef0a5c7ed181d877f1fdfde1e3fc1c6c28cfe")),
        .package(url: "https://github.com/tsolomko/SWCompression.git", .upToNextMajor(from: "4.5.0")),
        .package(name: "CertLogic", url: "https://github.com/eu-digital-green-certificates/dgc-certlogic-ios", .revision("b2c60391396b3f0e3c4bf0b6b9685cbae4a34c7a")),
        .package(url: "https://github.com/corona-warn-app/ASN1Decoder", .upToNextMajor(from: "1.8.1")),
        .package(name: "ENASecurity", path: "ENA/ENASecurity"),
        .package(url: "https://github.com/corona-warn-app/json-functions-swift", .branch("fix/date-and-decodable-support"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HealthCertificateToolkit",
            dependencies: ["SwiftCBOR", "base45-swift", "JSONSchema", "SWCompression", "CertLogic", "ASN1Decoder", "ENASecurity", .product(name: "jsonfunctions", package: "json-functions-swift")],
            resources: [
                .process("CertificateAccess/Ressources/CertificateSchema.json"),
                .process("RuleValidation/Ressources/dcc-validation-rule.json")
            ]
        ),
        .testTarget(
            name: "HealthCertificateToolkitTests",
            dependencies: ["HealthCertificateToolkit", "SwiftCBOR", "SWCompression"]
        )
    ]
)
