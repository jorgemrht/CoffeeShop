public struct ServerErrorDTO: Decodable, Sendable {
    public let code: String?
    public let message: String?
    public let details: [String:[String]]?
}
