#if DEBUG
import Foundation
import Domain

public final class MockCoffeeRepository: CoffeeRepository {

    public init() {}

    public func getCoffees() async throws -> [CoffeeShops] {
        [
            CoffeeShops(
                id: UUID(),
                name: "Espresso Bar",
                rating: 4.7,
                img: "https://placehold.co/200x200/8B4513/FFF?text=Espresso",
                description: "Bold and intense espresso specialties"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Cappuccino Corner",
                rating: 4.8,
                img: "https://placehold.co/200x200/D2691E/FFF?text=Cappuccino",
                description: "Creamy and smooth cappuccinos"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Latte Lounge",
                rating: 4.6,
                img: "https://placehold.co/200x200/CD853F/FFF?text=Latte",
                description: "Mild and milky latte creations"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Americano Avenue",
                rating: 4.5,
                img: "https://placehold.co/200x200/A0522D/FFF?text=Americano",
                description: "Strong yet smooth americano classics"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Mocha Mansion",
                rating: 4.9,
                img: "https://placehold.co/200x200/8B4513/FFF?text=Mocha",
                description: "Chocolate delight mochas"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Macchiato Market",
                rating: 4.4,
                img: "https://placehold.co/200x200/D2691E/FFF?text=Macchiato",
                description: "Espresso with a perfect touch"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Flat White Factory",
                rating: 4.8,
                img: "https://placehold.co/200x200/CD853F/FFF?text=FlatWhite",
                description: "Velvety microfoam masterpieces"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Cold Brew Cafe",
                rating: 4.3,
                img: "https://placehold.co/200x200/A0522D/FFF?text=ColdBrew",
                description: "Smooth and refreshing cold brews"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Affogato Atelier",
                rating: 4.9,
                img: "https://placehold.co/200x200/8B4513/FFF?text=Affogato",
                description: "Coffee meets dessert perfection"
            ),
            CoffeeShops(
                id: UUID(),
                name: "Cortado Central",
                rating: 4.7,
                img: "https://placehold.co/200x200/D2691E/FFF?text=Cortado",
                description: "Perfectly balanced cortados"
            )
        ]
    }

    public func getCoffeeDetail(id: UUID) async throws -> CoffeeDetail {
        CoffeeDetail(
            id: id,
            name: "Coffee \(id.uuidString.prefix(8))",
            rating: 4.8,
            img: "https://placehold.co/400x400/8B4513/FFF?text=Coffee",
            description: "A rich and smooth coffee with notes of chocolate and caramel, carefully selected from the finest beans in the region."
        )
    }
}
#endif
