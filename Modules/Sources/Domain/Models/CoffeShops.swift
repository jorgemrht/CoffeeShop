import Foundation

public struct CoffeeShops: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let rating: Double
    public let img: String
    public let description: String

    public init(id: UUID, name: String, rating: Double, img: String, description: String) {
        self.id = id
        self.name = name
        self.rating = rating
        self.img = img
        self.description = description
    }
}

extension CoffeeShops {
    static var placeholder: Self {
        .init(
            id: UUID(),
            name: "Coffee Shop Demo",
            rating: 4.8,
            img: "https://placehold.co/200x200.png",
            description: "The best specialty coffee in the city or not... believe me!"
        )
    }

    #if DEBUG
    static var mock: Self { .placeholder }
    #endif
}
