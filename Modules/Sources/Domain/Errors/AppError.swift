// DOCS: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/

public enum AppError: Error {
    case networkError
    case timeout
    case unauthorized
    case serverError(ServerError?)
    case internalError(Error?)
}
