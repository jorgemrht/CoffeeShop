public struct LoginRequestDTO: Encodable {
    public let email, password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
