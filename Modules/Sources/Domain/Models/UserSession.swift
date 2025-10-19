public struct UserSession: Sendable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}
