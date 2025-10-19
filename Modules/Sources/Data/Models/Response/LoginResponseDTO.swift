import Domain

public struct LoginResponseDTO: Decodable {
    public let token: String
}

public extension UserSession {
    init(_ dto: LoginResponseDTO) {
        self.init(token: dto.token)
    }
}
