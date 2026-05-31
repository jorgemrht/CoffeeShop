import Domain

public struct CoffeeShopsResponseDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let url: String?
}

extension CoffeeShopsResponseDTO {
    func toDomain() -> CoffeeShops {
        .init(id: id, title: title, description: description, image: image, url: url)
    }
}

extension [CoffeeShopsResponseDTO] {
    func toDomain() -> [CoffeeShops] {
        map { $0.toDomain() }
    }
}
