import Foundation

public struct CoffeeShops: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let image: String
    public let url: String?
    
    public init(id: String, title: String, description: String, image: String, url: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.url = url
    }

}

extension CoffeeShops {
    static var placeholder: Self {
        .init(
            id: UUID().uuidString,
            title: "Coffe Shops Demo",
            description: "the best specialty coffee in the city or not ... Believe me!",
            image: "https://placehold.co/200x200.png",
            url: "https://placehold.co/200x200.png"
        )
    }

    #if DEBUG
    static var mock: Self { .placeholder }
    #endif
}
