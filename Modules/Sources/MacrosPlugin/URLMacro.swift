import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Implementation of the `#URL` macro, which creates a non-optional URL from a static string.
/// The URL is validated at compile time, ensuring type safety.
///
/// ## Example
/// ```swift
/// let apiURL = #URL("https://api.example.com")
/// // Expands to: URL(string: "https://api.example.com")!
/// ```
///
/// ## Validation
/// - The macro requires a static string literal (no interpolation or variables)
/// - The string must represent a valid URL according to Foundation's URL parser
/// - Compilation fails with a clear error message if the URL is malformed
///
/// ## Source
/// Based on the official Swift Macros example from Apple:
/// https://github.com/swiftlang/swift-syntax/blob/main/Examples/Sources/MacroExamples/Implementation/Expression/URLMacro.swift
public enum URLMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Extract the argument from the macro invocation
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: Syntax(node),
                    message: MacroError.missingArgument
                )
            ])
        }

        // Ensure the argument is a string literal with a single segment
        guard let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: Syntax(argument),
                    message: MacroError.requiresStaticString
                )
            ])
        }

        // Validate that the string is a valid URL
        let urlString = literalSegment.content.text
        guard URL(string: urlString) != nil else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: Syntax(argument),
                    message: MacroError.malformedURL(urlString)
                )
            ])
        }

        // Generate the expansion: URL(string: "...")!
        // Note: The force unwrap is safe because we've validated the URL at compile time
        return "URL(string: \(argument))!"
    }
}

// MARK: - Error Messages

/// Error messages for the URL macro
enum MacroError: String, DiagnosticMessage {
    case missingArgument = "#URL requires exactly one argument"
    case requiresStaticString = "#URL requires a static string literal (no interpolation or variables)"
    case malformedURL

    var message: String {
        switch self {
        case .missingArgument, .requiresStaticString:
            return rawValue
        case .malformedURL:
            return "Malformed URL"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "URLMacro", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }

    /// Creates a malformed URL error with the invalid URL string
    static func malformedURL(_ urlString: String) -> MacroError {
        // We can't pass the string through the enum,
        // but we provide it in the context where this is used
        .malformedURL
    }
}
