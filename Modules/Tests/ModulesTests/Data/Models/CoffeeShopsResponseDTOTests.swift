import Testing
import Foundation
@testable import Domain
@testable import Data

struct CoffeeShopsResponseDTOTests {

    @Test func coffeeShopsResponseDTOToCoffeeShop() throws {
        // Given
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

        // When
        let coffeeShop = dto.toDomain

        // Then
        #expect(coffeeShop.id == "shop789")
        #expect(coffeeShop.title == "Stumptown")
        #expect(coffeeShop.description == "Portland-based roaster")
        #expect(coffeeShop.image == "https://example.com/stumptown.jpg")
        #expect(coffeeShop.url == "https://stumptown.com")
    }

    @Test func coffeeShopsResponseDTOArrayToCoffeeShopArray() throws {
        // Given
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

        // When
        let coffeeShops = dtos.toDomain()

        // Then
        #expect(coffeeShops.count == 2)
        #expect(coffeeShops[0].id == "shop1")
        #expect(coffeeShops[0].title == "Coffee Shop 1")
        #expect(coffeeShops[1].id == "shop2")
        #expect(coffeeShops[1].url == nil)
    }
}
