public struct RegisterRequestDTO: Encodable {
    public let email, password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
