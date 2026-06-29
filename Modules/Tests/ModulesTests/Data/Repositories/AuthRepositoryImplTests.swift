import Foundation
import Synchronization
import Testing
@testable import Data

private typealias AuthRepositoryURLProtocolHandler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
private let authRepositoryURLProtocolHandler = Mutex<AuthRepositoryURLProtocolHandler?>(nil)

struct AuthRepositoryImplTests {
    @Test func loginSavesTokenForAuthenticatedRequests() async throws {
        let keychainDataSource = InMemoryKeychainDataSource()
        let tokenStore = TokenStore(
            keychainDataSource: keychainDataSource,
            service: "AuthRepositoryImplTests"
        )
        let client = NetworkClient(
            baseURL: URL(string: "https://api.test.com")!,
            session: URLSession(configuration: .authRepositoryMock),
            interceptors: [
                BearerAuthInterceptor(
                    tokenProvider: {
                        try? await tokenStore.token()
                    }
                )
            ],
            subsystem: "AuthRepositoryImplTests",
            tokenStore: tokenStore
        )
        let repository = AuthRepositoryImpl(
            networkClient: client,
            deviceIdentityDataSource: TestDeviceIdentityDataSource()
        )
        defer {
            authRepositoryURLProtocolHandler.withLock { $0 = nil }
        }

        authRepositoryURLProtocolHandler.withLock {
            $0 = { request in
                #expect(request.url?.path == "/users/login")

                let data = try JSONSerialization.data(withJSONObject: [
                    "username": "jorge",
                    "email": "jorge@mrht.dev",
                    "is_validate_email": true,
                    "token": "session-token"
                ])
                return (Self.httpResponse(for: request), data)
            }
        }

        _ = try await repository.login(email: "jorge@mrht.dev", password: "123456")

        authRepositoryURLProtocolHandler.withLock {
            $0 = { request in
                #expect(request.url?.path == "/profile")
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer session-token")
                return (Self.httpResponse(for: request), Data())
            }
        }

        _ = try await client.request(APIEndpoint(path: "/profile", method: .GET))
    }

    private static func httpResponse(for request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}

private struct TestDeviceIdentityDataSource: DeviceIdentityDataSource {
    func deviceId() throws -> String {
        "test-device-id"
    }
}

private final class InMemoryKeychainDataSource: KeychainDataSource, @unchecked Sendable {
    private let values = Mutex<[KeychainItemDescriptor: Data]>([:])

    func save(_ data: Data, for item: KeychainItemDescriptor) throws {
        try values.withLock {
            guard $0[item] == nil else {
                throw KeychainDataSourceError.duplicateItem
            }
            $0[item] = data
        }
    }

    func save(_ value: String, for item: KeychainItemDescriptor) throws {
        try save(Data(value.utf8), for: item)
    }

    func readData(for item: KeychainItemDescriptor) throws -> Data? {
        values.withLock { $0[item] }
    }

    func readString(for item: KeychainItemDescriptor) throws -> String? {
        guard let data = values.withLock({ $0[item] }) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func update(_ data: Data, for item: KeychainItemDescriptor) throws {
        try values.withLock {
            guard $0[item] != nil else {
                throw KeychainDataSourceError.itemNotFound
            }
            $0[item] = data
        }
    }

    func update(_ value: String, for item: KeychainItemDescriptor) throws {
        try update(Data(value.utf8), for: item)
    }

    func upsert(_ data: Data, for item: KeychainItemDescriptor) throws {
        values.withLock { $0[item] = data }
    }

    func upsert(_ value: String, for item: KeychainItemDescriptor) throws {
        try upsert(Data(value.utf8), for: item)
    }

    func deleteValue(for item: KeychainItemDescriptor) throws {
        values.withLock { $0[item] = nil }
    }

    func exists(for item: KeychainItemDescriptor) throws -> Bool {
        values.withLock { $0[item] != nil }
    }
}

private final class AuthRepositoryMockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let handler = authRepositoryURLProtocolHandler.withLock({ $0 }) else {
                throw URLError(.badServerResponse)
            }

            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

private extension URLSessionConfiguration {
    static var authRepositoryMock: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [AuthRepositoryMockURLProtocol.self]
        return configuration
    }
}
