public struct ServerError: Sendable {
    public let identifier: String?
    public let statusCode: Int?
    public let message: String?

    public init(identifier: String?, statusCode: Int?, message: String?) {
        self.identifier = identifier
        self.statusCode = statusCode
        self.message = message
    }
}
