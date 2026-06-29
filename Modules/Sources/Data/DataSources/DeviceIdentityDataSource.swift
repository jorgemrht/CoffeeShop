import Foundation

protocol DeviceIdentityDataSource: Sendable {
    func deviceId() throws -> String
}

struct DeviceIdentityDataSourceImpl: DeviceIdentityDataSource {
    private let keychainDataSource: any KeychainDataSource
    private let descriptor: KeychainItemDescriptor

    init(
        keychainDataSource: any KeychainDataSource,
        service: String
    ) {
        self.keychainDataSource = keychainDataSource
        self.descriptor = KeychainItemDescriptor(
            service: service,
            account: KeychainAccountName.deviceId,
            accessibility: .afterFirstUnlockThisDeviceOnly
        )
    }

    func deviceId() throws -> String {
        if let storedValue = try keychainDataSource.readString(for: descriptor), !storedValue.isEmpty {
            return storedValue
        }

        let value = UUID().uuidString
        try keychainDataSource.upsert(value, for: descriptor)
        return value
    }
}
