import Domain

public struct CoffeeShopsResponseDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let image: String
    let url: String?
}

extension CoffeeShopsResponseDTO {
    var toDomain: CoffeeShops {
        .init(id: id, title: title, description: description, image: image, url: url)
    }
}

extension [CoffeeShopsResponseDTO] {
    func toDomain() -> [CoffeeShops] {
        map(\.toDomain)
    }
}
