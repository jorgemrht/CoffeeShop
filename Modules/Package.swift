// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CoffeShopModules",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v14)],
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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "602.0.0")
    ],
    targets: [
        .target(
            name: "AppNavigation",
            dependencies: [
                "SharedCore",
                "FeatureSplash",
                "FeatureLogin",
                "FeatureRegister",
                "FeatureShops"
            ]
        ),
        .target(
            name: "SharedCore",
            dependencies: [
                "Data",
                "Domain",
                "DesignSystem",
                "TestHelpers",
                "Tracking"
            ]
        ),
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                "Macros"
            ]
        ),
        .target(
            name: "DesignSystem"
        ),
        .target(
            name: "Domain",
            dependencies: [ ]
        ),
        .target(
            name: "FeatureLogin",
            dependencies: [
                "SharedCore",
                "FeatureRegister"
            ]
        ),
        .target(
            name: "FeatureRegister",
            dependencies: [
                "SharedCore"
            ]
        ),
        .target(
            name: "FeatureSplash",
            dependencies: [
                "SharedCore"
            ]
        ),
        .target(
            name: "FeatureShops",
            dependencies: [
                "DesignSystem"
            ]
        ),
        .target(
            name: "Tracking",
            dependencies: [
                "Macros",
            ]
        ),
        .macro(
            name: "MacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"), // Optional but recommended
                .product(name: "SwiftSyntax", package: "swift-syntax"), // Optional but recommended
            ]
        ),
        .target(
            name: "Macros",
            dependencies: ["MacrosPlugin"]
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
                "Domain",
                "Tracking",
                "Data"
            ]
        ),
        .testTarget(
            name: "ModulesTests",
            dependencies: [
                "SharedCore",
                "Tracking",
                "TestHelpers"
            ]
        )
    ]
)
