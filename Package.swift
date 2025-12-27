// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MRDLNA",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MRDLNA",
            targets: ["MRDLNA"]),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5")
    ],
    targets: [
        .target(
            name: "MRDLNA",
            dependencies: [
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket")
            ],
            path: "Sources/MRDLNA",
            publicHeadersPath: "Classes",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("$(SDKROOT)/usr/include/libxml2"),
                .unsafeFlags(["-fno-objc-arc"], .when(platforms: [.iOS], configuration: nil))
            ],
            linkerSettings: [
                .linkedLibrary("icucore"),
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
                .linkedLibrary("xml2"),
                .linkedFramework("Foundation")
            ]
        )
    ]
)

