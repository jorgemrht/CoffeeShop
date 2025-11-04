import Testing
import Foundation
@testable import Data

struct ShopEndpointsTests {

    @Test func shopsEndpoint() {
        // Given/When
        let endpoint = ShopEndpoints.shops.endpoint

        // Then
        #expect(endpoint.path == "/shops")
        #expect(endpoint.method == .GET)
        #expect(endpoint.body == nil)
    }

    @Test func shopDetailEndpoint() {
        // Given
        let shopId = 42

        // When
        let endpoint = ShopEndpoints.detail(id: shopId).endpoint

        // Then
        #expect(endpoint.path == "/shops/42")
        #expect(endpoint.method == .GET)
        #expect(endpoint.body == nil)
    }
}
