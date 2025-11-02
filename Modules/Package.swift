// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CoffeShopModules",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
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
            name: "FeatureShops",
            dependencies: [
                "DesignSystem"
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
        .testTarget(
            name: "ModulesTests",
            dependencies: ["SharedCore"]
        )
    ]
)
