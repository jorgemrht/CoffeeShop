import Foundation

/// Creates a compile-time validated URL from a static string literal.
///
/// This macro validates the URL at compile time and produces a non-optional `URL` instance.
/// If the string is not a valid URL, compilation will fail with a clear error message.
///
/// ## Example
/// ```swift
/// import Macros
///
/// let apiURL = #URL("https://api.example.com")
/// // Type: URL (not URL?)
/// ```
///
/// ## Benefits
/// - **Compile-time validation**: Catches invalid URLs during compilation, not at runtime
/// - **Type safety**: Returns `URL` instead of `URL?`, eliminating optional handling
/// - **Zero runtime overhead**: Validation happens at compile time
/// - **Clear error messages**: Shows exactly which URL is invalid and where
///
/// ## Requirements
/// - The argument must be a static string literal (no interpolation or variables)
/// - The string must be a valid URL according to Foundation's `URL(string:)` initializer
///
/// ## Comparison with Standard Approaches
///
/// **Without macro:**
/// ```swift
/// // Option 1: Force unwrap (unsafe)
/// let url = URL(string: "https://api.example.com")!
///
/// // Option 2: Optional handling (verbose)
/// guard let url = URL(string: "https://api.example.com") else {
///     fatalError("Invalid URL")
/// }
/// ```
///
/// **With macro:**
/// ```swift
/// let url = #URL("https://api.example.com")
/// // Clean, safe, validated at compile time
/// ```
///
/// ## Error Examples
/// ```swift
/// let bad1 = #URL("not a url")
/// // ❌ Error: Malformed URL
///
/// let bad2 = #URL(someVariable)
/// // ❌ Error: #URL requires a static string literal
///
/// let bad3 = #URL("https://\(domain)/path")
/// // ❌ Error: #URL requires a static string literal (no interpolation)
/// ```
///
/// ## Implementation
/// This is a freestanding expression macro implemented using Swift's macro system (Swift 5.9+).
/// The implementation is in the MacrosPlugin target and uses SwiftSyntax for compile-time validation.
///
/// ## References
/// - Swift Evolution SE-0382: Expression Macros
/// - Apple's Swift Macros documentation
/// - Official URL macro example: https://github.com/swiftlang/swift-syntax
@freestanding(expression)
public macro URL(_ stringLiteral: StaticString) -> URL = #externalMacro(module: "MacrosPlugin", type: "URLMacro")
