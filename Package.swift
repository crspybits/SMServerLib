// swift-tools-version:4.1
// Adapted from https://github.com/IBM-Swift/Kitura-CredentialsGoogle

import PackageDescription

let package = Package(
    name: "SMServerLib",
    products: [
        // sudo apt-get install openssl libssl-dev uuid-dev
        //      is necessary on Linux to get this working
        .library(
            name: "SMServerLib",
            targets: ["SMServerLib"]
        )
    ],
    dependencies: [
            .package(url: "https://github.com/PerfectlySoft/Perfect.git", .upToNextMajor(from: "3.1.0"))
        ],
    targets: [
        .target(
            name: "SMServerLib",
            dependencies: ["PerfectLib"]
        ),
        .testTarget(
            name: "SMServerLibTests",
            dependencies: ["PerfectLib", "SMServerLib"]
        )
    ]
)
