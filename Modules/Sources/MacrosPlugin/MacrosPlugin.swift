import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin that provides custom Swift macros for the CoffeeShop project.
///
/// ## Available Macros
/// - `#URL`: Creates a compile-time validated URL from a string literal
///
/// ## Usage
/// This plugin is automatically loaded by the Swift compiler when the Macros module is imported.
@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        URLMacro.self,
    ]
}
