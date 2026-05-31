import Foundation
import Testing
@testable import Data

struct AppIntegrityClientDataTests {

    @Test func signedHeadersKeepOnlyPayloadCryptoHeaders() {
        // Given
        let headers = [
            "Content-Type": "application/json",
            "X-App-Key-Id": "key-id",
            "X-App-Public-Key": "public-key",
            "X-App-Crypto-Algorithm": "P256-HKDF-SHA256-AES-GCM",
            "Authorization": "Bearer token"
        ]

        // When
        let signedHeaders = AppIntegrityClientData.signedHeaders(from: headers)

        // Then
        #expect(signedHeaders == [
            "content-type": "application/json",
            "x-app-crypto-algorithm": "P256-HKDF-SHA256-AES-GCM",
            "x-app-key-id": "key-id",
            "x-app-public-key": "public-key"
        ])
    }

    @Test func clientDataCanonicalizesRequestWithBodyAndSignedHeaders() {
        // Given
        let body = Data(#"{"desc":"CoffeeShop"}"#.utf8)
        let headers = [
            "content-type": "application/json",
            "x-app-crypto-algorithm": "P256-HKDF-SHA256-AES-GCM",
            "x-app-key-id": "key-id",
            "x-app-public-key": "public-key"
        ]

        // When
        let data = AppIntegrityClientData.data(
            challenge: "challenge",
            method: "post",
            path: "/test/encrypted?include=date",
            body: body,
            headers: headers
        )

        // Then
        let expected = [
            "challenge",
            "POST",
            "/test/encrypted?include=date",
            AppIntegrityClientData.bodyHash(for: body),
            [
                "content-type:application/json",
                "x-app-crypto-algorithm:P256-HKDF-SHA256-AES-GCM",
                "x-app-key-id:key-id",
                "x-app-public-key:public-key"
            ].joined(separator: "\n")
        ].joined(separator: "\n")

        #expect(String(decoding: data, as: UTF8.self) == expected)
    }
}
