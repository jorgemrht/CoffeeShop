import Foundation

public struct CoffeeDetail: Identifiable, Hashable, Sendable {
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
