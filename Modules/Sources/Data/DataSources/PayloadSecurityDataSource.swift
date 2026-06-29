import Foundation

protocol PayloadSecurityDataSource: Sendable {
    func clientSeed() throws -> String
    func verificationKey() throws -> String
}

struct PayloadSecurityDataSourceImpl: PayloadSecurityDataSource {
    private let keychainDataSource: any KeychainDataSource
    private let keychainService: String

    init(
        keychainDataSource: any KeychainDataSource,
        keychainService: String
    ) {
        self.keychainDataSource = keychainDataSource
        self.keychainService = keychainService
    }

    func clientSeed() throws -> String {
        try value(
            for: StaticSlots.first(service: keychainService),
            fallback: StaticPayload.first
        )
    }

    func verificationKey() throws -> String {
        try value(
            for: StaticSlots.second(service: keychainService),
            fallback: StaticPayload.second
        )
    }

    private func value(
        for descriptor: KeychainItemDescriptor,
        fallback: String
    ) throws -> String {
        if let storedValue = try keychainDataSource.readString(for: descriptor), !storedValue.isEmpty {
            return storedValue
        }

        try keychainDataSource.upsert(fallback, for: descriptor)
        return fallback
    }
}

private enum StaticSlots {
    static func first(service: String) -> KeychainItemDescriptor {
        KeychainItemDescriptor(
            service: service,
            account: StaticPayload.decode([27, 10, 10, 5, 19, 30, 31, 20, 14, 19, 14, 3, 5, 14, 21, 17, 31, 20]),
            accessibility: .whenUnlockedThisDeviceOnly
        )
    }

    static func second(service: String) -> KeychainItemDescriptor {
        KeychainItemDescriptor(
            service: service,
            account: StaticPayload.decode([9, 31, 8, 12, 31, 8, 5, 10, 15, 24, 22, 19, 25, 5, 17, 31, 3, 5, 12, 104]),
            accessibility: .whenUnlockedThisDeviceOnly
        )
    }
}

private enum StaticPayload {
    private static let mask: UInt8 = 0x5A

    static let first = decode([
        110, 16, 98, 24, 107, 111, 30, 104, 119, 27, 99, 28,
        109, 119, 110, 27, 107, 25, 119, 98, 27, 111, 30, 119,
        28, 110, 104, 30, 107, 25, 99, 108, 105, 24, 111, 107
    ])

    static let second = [
        decode([119, 119, 119, 119, 119, 24, 31, 29, 19, 20, 122, 10, 15, 24, 22, 19, 25, 122, 17, 31, 3, 119, 119, 119, 119, 119]),
        decode([
            23, 28, 49, 45, 31, 45, 3, 18, 17, 53, 0, 19, 32, 48,
            106, 25, 27, 11, 3, 19, 17, 53, 0, 19, 32, 48, 106, 30,
            27, 11, 57, 30, 11, 61, 27, 31, 104, 110, 105, 57, 52, 60,
            9, 29, 45, 11, 62, 27, 61, 52, 29, 3, 42, 113, 45, 56,
            16, 27, 52, 45, 45, 29, 2, 55
        ]),
        decode([
            43, 43, 113, 60, 40, 104, 49, 23, 0, 2, 49, 53, 110, 47,
            45, 29, 11, 16, 54, 34, 98, 29, 17, 40, 22, 59, 31, 63,
            108, 45, 62, 50, 9, 14, 35, 15, 49, 23, 28, 41, 52, 60,
            53, 9, 19, 2, 60, 14, 61, 11, 41, 48, 47, 14, 18, 50,
            34, 45, 103, 103
        ]),
        decode([119, 119, 119, 119, 119, 31, 20, 30, 122, 10, 15, 24, 22, 19, 25, 122, 17, 31, 3, 119, 119, 119, 119, 119])
    ].joined(separator: "\n")

    static func decode(_ bytes: [UInt8]) -> String {
        String(decoding: bytes.map { $0 ^ mask }, as: UTF8.self)
    }
}
