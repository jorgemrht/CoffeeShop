import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - CoffeeShopsResponseDTO Tests

struct CoffeeShopsResponseDTOTests {

    @Test func coffeeShopsResponseDTODecodesCorrectly() throws {
        // Given: Valid coffee shop JSON
        let json = """
        {
            "id": "shop123",
            "title": "Blue Bottle Coffee",
            "description": "Specialty coffee roaster",
            "image": "https://example.com/image.jpg",
            "url": "https://bluebottle.com"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding CoffeeShopsResponseDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(CoffeeShopsResponseDTO.self, from: data)

        // Then: Should decode all properties correctly
        #expect(dto.id == "shop123")
        #expect(dto.title == "Blue Bottle Coffee")
        #expect(dto.description == "Specialty coffee roaster")
        #expect(dto.image == "https://example.com/image.jpg")
        #expect(dto.url == "https://bluebottle.com")
    }

    @Test func coffeeShopsResponseDTODecodesWithNilURL() throws {
        // Given: JSON with nil URL
        let json = """
        {
            "id": "shop456",
            "title": "Local Coffee",
            "description": "Community cafe",
            "image": "https://example.com/local.jpg",
            "url": null
        }
        """
        let data = Data(json.utf8)

        // When: Decoding CoffeeShopsResponseDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(CoffeeShopsResponseDTO.self, from: data)

        // Then: Should decode with nil URL
        #expect(dto.id == "shop456")
        #expect(dto.title == "Local Coffee")
        #expect(dto.url == nil)
    }

    @Test func coffeeShopsResponseDTOMapsToDomain() throws {
        // Given: A CoffeeShopsResponseDTO
        let json = """
        {
            "id": "shop789",
            "title": "Stumptown",
            "description": "Portland-based roaster",
            "image": "https://example.com/stumptown.jpg",
            "url": "https://stumptown.com"
        }
        """
        let data = Data(json.utf8)
        let dto = try JSONDecoder().decode(CoffeeShopsResponseDTO.self, from: data)

        // When: Mapping to Domain
        let coffeeShop = dto.toDomain

        // Then: Domain model should have same values
        #expect(coffeeShop.id == "shop789")
        #expect(coffeeShop.title == "Stumptown")
        #expect(coffeeShop.description == "Portland-based roaster")
        #expect(coffeeShop.image == "https://example.com/stumptown.jpg")
        #expect(coffeeShop.url == "https://stumptown.com")
    }

    @Test func coffeeShopsArrayMapsToDomainArray() throws {
        // Given: An array of CoffeeShopsResponseDTO
        let json = """
        [
            {
                "id": "shop1",
                "title": "Coffee Shop 1",
                "description": "First shop",
                "image": "https://example.com/1.jpg",
                "url": "https://shop1.com"
            },
            {
                "id": "shop2",
                "title": "Coffee Shop 2",
                "description": "Second shop",
                "image": "https://example.com/2.jpg",
                "url": null
            }
        ]
        """
        let data = Data(json.utf8)
        let dtos = try JSONDecoder().decode([CoffeeShopsResponseDTO].self, from: data)

        // When: Mapping to Domain array
        let coffeeShops = dtos.toDomain()

        // Then: Should have 2 coffee shops with correct values
        #expect(coffeeShops.count == 2)
        #expect(coffeeShops[0].id == "shop1")
        #expect(coffeeShops[0].title == "Coffee Shop 1")
        #expect(coffeeShops[1].id == "shop2")
        #expect(coffeeShops[1].url == nil)
    }

    @Test func coffeeShopsResponseDTODecodesWithSnakeCaseKeys() throws {
        // Given: JSON with snake_case keys (if API uses this format)
        let json = """
        {
            "id": "shop_abc",
            "title": "Test Shop",
            "description": "Test Description",
            "image": "https://example.com/test.jpg",
            "url": "https://test.com"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding with decoderDefault
        let decoder = JSONDecoder.decoderDefault()
        let dto = try decoder.decode(CoffeeShopsResponseDTO.self, from: data)

        // Then: Should decode correctly
        #expect(dto.id == "shop_abc")
        #expect(dto.title == "Test Shop")
    }

    @Test func emptyArrayMapsToEmptyDomainArray() {
        // Given: An empty array of DTOs
        let dtos: [CoffeeShopsResponseDTO] = []

        // When: Mapping to Domain
        let coffeeShops = dtos.toDomain()

        // Then: Should return empty array
        #expect(coffeeShops.isEmpty)
    }
}
