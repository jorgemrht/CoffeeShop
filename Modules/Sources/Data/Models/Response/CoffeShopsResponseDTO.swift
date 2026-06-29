import Foundation
import Domain

public struct CoffeeShopsResponseDTO: Decodable {
    let id: UUID
    let name: String
    let rating: Double
    let img: String
    let description: String
}

extension CoffeeShopsResponseDTO {
    func toDomain() -> CoffeeShops {
        .init(id: id, name: name, rating: rating, img: img, description: description)
    }
}

extension [CoffeeShopsResponseDTO] {
    func toDomain() -> [CoffeeShops] {
        map { $0.toDomain() }
    }
}
