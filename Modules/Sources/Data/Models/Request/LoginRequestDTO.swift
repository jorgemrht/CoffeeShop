public struct LoginRequestDTO: Encodable {
    public let email: String
    public let password: String
    public let deviceId: String

    public init(email: String, password: String, deviceId: String) {
        self.email = email
        self.password = password
        self.deviceId = deviceId
    }
}
