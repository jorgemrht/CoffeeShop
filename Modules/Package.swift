// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let packageSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
]

let uiSwiftSettings: [SwiftSetting] = packageSwiftSettings + [
    .defaultIsolation(MainActor.self)
]

let package = Package(
    name: "CoffeShopModules",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]
        ),
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        ),
        .library(
            name: "Macros",
            targets: ["Macros"]
        ),
        .library(
            name: "CoffeShopModules",
            targets: ["Data", "Domain", "DesignSystem", "Macros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "603.0.1")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                "Macros"
            ],
            swiftSettings: packageSwiftSettings
        ),
        .target(
            name: "Domain",
            dependencies: [],
            swiftSettings: packageSwiftSettings
        ),
        .target(
            name: "DesignSystem",
            dependencies: [],
            swiftSettings: uiSwiftSettings
        ),
        .macro(
            name: "MacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            swiftSettings: packageSwiftSettings
        ),
        .target(
            name: "Macros",
            dependencies: ["MacrosPlugin"],
            swiftSettings: packageSwiftSettings
        ),
        .testTarget(
            name: "ModulesTests",
            dependencies: [
                "Data",
                "Domain"
            ],
            swiftSettings: packageSwiftSettings
        )
    ]
)
