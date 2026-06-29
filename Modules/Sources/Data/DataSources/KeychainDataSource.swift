import Foundation
import Security

public protocol KeychainDataSource: Sendable {
    func save(_ data: Data, for item: KeychainItemDescriptor) throws
    func save(_ value: String, for item: KeychainItemDescriptor) throws
    func readData(for item: KeychainItemDescriptor) throws -> Data?
    func readString(for item: KeychainItemDescriptor) throws -> String?
    func update(_ data: Data, for item: KeychainItemDescriptor) throws
    func update(_ value: String, for item: KeychainItemDescriptor) throws
    func upsert(_ data: Data, for item: KeychainItemDescriptor) throws
    func upsert(_ value: String, for item: KeychainItemDescriptor) throws
    func deleteValue(for item: KeychainItemDescriptor) throws
    func exists(for item: KeychainItemDescriptor) throws -> Bool
}

public struct KeychainDataSourceImpl: KeychainDataSource {
    public init() { }

    public func save(_ data: Data, for item: KeychainItemDescriptor) throws {
        var query = baseQuery(for: item)
        query[kSecAttrAccessible as String] = item.accessibility.secAttrValue
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw KeychainDataSourceError.duplicateItem
        default:
            throw KeychainDataSourceError.unexpectedStatus(status)
        }
    }

    public func save(_ value: String, for item: KeychainItemDescriptor) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainDataSourceError.invalidStringData
        }

        try save(data, for: item)
    }

    public func readData(for item: KeychainItemDescriptor) throws -> Data? {
        var query = baseQuery(for: item)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainDataSourceError.unexpectedStatus(status)
        }
    }

    public func readString(for item: KeychainItemDescriptor) throws -> String? {
        guard let data = try readData(for: item) else {
            return nil
        }

        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainDataSourceError.invalidStringData
        }

        return value
    }

    public func update(_ data: Data, for item: KeychainItemDescriptor) throws {
        let query = baseQuery(for: item)
        let attributes: [String: Any] = [
            kSecAttrAccessible as String: item.accessibility.secAttrValue,
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            throw KeychainDataSourceError.itemNotFound
        default:
            throw KeychainDataSourceError.unexpectedStatus(status)
        }
    }

    public func update(_ value: String, for item: KeychainItemDescriptor) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainDataSourceError.invalidStringData
        }

        try update(data, for: item)
    }

    public func upsert(_ data: Data, for item: KeychainItemDescriptor) throws {
        do {
            try save(data, for: item)
        } catch KeychainDataSourceError.duplicateItem {
            try update(data, for: item)
        }
    }

    public func upsert(_ value: String, for item: KeychainItemDescriptor) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainDataSourceError.invalidStringData
        }

        try upsert(data, for: item)
    }

    public func deleteValue(for item: KeychainItemDescriptor) throws {
        let status = SecItemDelete(baseQuery(for: item) as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainDataSourceError.unexpectedStatus(status)
        }
    }

    public func exists(for item: KeychainItemDescriptor) throws -> Bool {
        var query = baseQuery(for: item)
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainDataSourceError.unexpectedStatus(status)
        }
    }

    private func baseQuery(for item: KeychainItemDescriptor) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: item.service,
            kSecAttrAccount as String: item.account
        ]

        if let accessGroup = item.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}

public enum KeychainDataSourceError: Error {
    case duplicateItem
    case itemNotFound
    case invalidStringData
    case unexpectedStatus(OSStatus)
}

public struct KeychainItemDescriptor: Sendable, Hashable {
    public let service: String
    public let account: String
    public let accessGroup: String?
    public let accessibility: KeychainAccessibility

    public init(
        service: String,
        account: String,
        accessGroup: String? = nil,
        accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
    ) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.accessibility = accessibility
    }
}

public enum KeychainAccessibility: Sendable {
    case whenUnlocked
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly
}

private extension KeychainAccessibility {
    var secAttrValue: CFString {
        switch self {
        case .whenUnlocked:
            kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
