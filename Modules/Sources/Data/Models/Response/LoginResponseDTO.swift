import Domain

public struct LoginResponseDTO: Decodable {
    public let token: String
}

extension LoginResponseDTO {
    func toDomain() -> UserSession {
        .init(token: token)
    }
}
