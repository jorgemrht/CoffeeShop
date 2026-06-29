import Foundation

enum KeychainAccountName {
    private static let mask: UInt8 = 0x5A

    static let sessionToken = decode([
        41, 63, 41, 41, 51, 53, 52, 119, 46, 53, 49, 63, 52
    ])

    static let deviceId = decode([
        62, 63, 44, 51, 57, 63, 119, 51, 62
    ])

    private static func decode(_ bytes: [UInt8]) -> String {
        String(decoding: bytes.map { $0 ^ mask }, as: UTF8.self)
    }
}
