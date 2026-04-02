import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum URLMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: Syntax(node),
                    message: MacroError.missingArgument
                )
            ])
        }

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

        let urlString = literalSegment.content.text
        guard URL(string: urlString) != nil else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: Syntax(argument),
                    message: MacroError.malformedURL(urlString)
                )
            ])
        }

        return "URL(string: \(argument))!"
    }
}

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

    static func malformedURL(_ urlString: String) -> MacroError {
        .malformedURL
    }
}
