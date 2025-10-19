// DOCS: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/

public enum AppError: Error, Sendable {
    case offline, timeout
    case server(status: Int, message: String?)
    case decoding
    case unknown(message: String?)
}
