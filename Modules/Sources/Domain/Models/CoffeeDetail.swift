import Foundation

public struct CoffeeDetail: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let specialty: String
    public let summary: String

    public init(id: Int, name: String, specialty: String, summary: String) {
        self.id = id
        self.name = name
        self.specialty = specialty
        self.summary = summary
    }
}
