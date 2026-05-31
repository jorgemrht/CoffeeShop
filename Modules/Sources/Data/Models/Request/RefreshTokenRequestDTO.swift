public struct RefreshTokenRequestDTO: Encodable {
    let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
