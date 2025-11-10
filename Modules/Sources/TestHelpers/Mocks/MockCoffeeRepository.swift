import Foundation
import Domain

public final class MockCoffeeRepository: CoffeeRepository {

    public init() {}

    public func getCoffees() async throws -> [CoffeeShops] {
        [
            CoffeeShops(
                id: "1",
                title: "Espresso Bar",
                description: "Bold and intense espresso specialties",
                image: "https://placehold.co/200x200/8B4513/FFF?text=Espresso"
            ),
            CoffeeShops(
                id: "2",
                title: "Cappuccino Corner",
                description: "Creamy and smooth cappuccinos",
                image: "https://placehold.co/200x200/D2691E/FFF?text=Cappuccino"
            ),
            CoffeeShops(
                id: "3",
                title: "Latte Lounge",
                description: "Mild and milky latte creations",
                image: "https://placehold.co/200x200/CD853F/FFF?text=Latte"
            ),
            CoffeeShops(
                id: "4",
                title: "Americano Avenue",
                description: "Strong yet smooth americano classics",
                image: "https://placehold.co/200x200/A0522D/FFF?text=Americano"
            ),
            CoffeeShops(
                id: "5",
                title: "Mocha Mansion",
                description: "Chocolate delight mochas",
                image: "https://placehold.co/200x200/8B4513/FFF?text=Mocha"
            ),
            CoffeeShops(
                id: "6",
                title: "Macchiato Market",
                description: "Espresso with a perfect touch",
                image: "https://placehold.co/200x200/D2691E/FFF?text=Macchiato"
            ),
            CoffeeShops(
                id: "7",
                title: "Flat White Factory",
                description: "Velvety microfoam masterpieces",
                image: "https://placehold.co/200x200/CD853F/FFF?text=FlatWhite"
            ),
            CoffeeShops(
                id: "8",
                title: "Cold Brew Cafe",
                description: "Smooth and refreshing cold brews",
                image: "https://placehold.co/200x200/A0522D/FFF?text=ColdBrew"
            ),
            CoffeeShops(
                id: "9",
                title: "Affogato Atelier",
                description: "Coffee meets dessert perfection",
                image: "https://placehold.co/200x200/8B4513/FFF?text=Affogato"
            ),
            CoffeeShops(
                id: "10",
                title: "Cortado Central",
                description: "Perfectly balanced cortados",
                image: "https://placehold.co/200x200/D2691E/FFF?text=Cortado"
            )
        ]
    }

    public func getCoffeeDetail(id: Int) async throws -> CoffeeDetail {
        CoffeeDetail(
            id: id,
            name: "Coffee #\(id)",
            specialty: "Arabica Premium",
            summary: "A rich and smooth coffee with notes of chocolate and caramel, carefully selected from the finest beans in the region."
        )
    }
}
