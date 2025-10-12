// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoffeShopModules",
    defaultLocalization: "en",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "CoffeShopModules",
            targets: [
                "AppNavigation",
                "DesignSystem",
                "SharedCore"
            ]
        ),
    ],
    targets: [
        .target(
            name: "AppNavigation",
            dependencies: [
                "FeatureShops"
            ]
        ),
        .target(
            name: "SharedCore",
            dependencies: [
                "Data",
                "Domain"
            ]
        ),
        .target(
            name: "Data",
            dependencies: [
                "Domain"
            ]
        ),
        .target(
            name: "DesignSystem",
            // dependencies: [ ]
        ),
        .target(
            name: "Domain",
            dependencies: [ ]
        ),
        .target(
            name: "FeatureShops",
            dependencies: [
                "DesignSystem"
            ]
        ),
        .testTarget(
            name: "ModulesTests",
            dependencies: ["SharedCore"]
        )
    ]
)
