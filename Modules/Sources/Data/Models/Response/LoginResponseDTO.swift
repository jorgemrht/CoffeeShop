import Domain

public struct LoginResponseDTO: Decodable {
    public let username: String
    public let email: String
    public let isValidateEmail: Bool
    public let token: String

    public init(
        username: String,
        email: String,
        isValidateEmail: Bool,
        token: String,
    ) {
        self.username = username
        self.email = email
        self.isValidateEmail = isValidateEmail
        self.token = token
    }
}

extension LoginResponseDTO {
    func toDomain() -> UserSession {
        .init(
            username: username,
            email: email,
            isValidateEmail: isValidateEmail,
            token: token
        )
    }
}
