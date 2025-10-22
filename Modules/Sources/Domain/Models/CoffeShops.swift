import Foundation

public struct CoffeShops: Identifiable, Hashable, Sendable {
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

