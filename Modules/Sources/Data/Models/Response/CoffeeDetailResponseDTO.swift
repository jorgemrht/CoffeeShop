import Foundation
import Domain

public struct CoffeeDetailResponseDTO: Decodable {
    public let id: UUID
    public let name: String
    public let rating: Double
    public let img: String
    public let description: String
}

extension CoffeeDetailResponseDTO {
    func toDomain() -> CoffeeDetail {
        CoffeeDetail(
            id: id,
            name: name,
            rating: rating,
            img: img,
            description: description
        )
    }
}
