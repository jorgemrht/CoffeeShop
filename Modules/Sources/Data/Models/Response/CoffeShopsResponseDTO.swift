import Domain

struct CoffeShopsResponseDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let image: String
    let url: String?
}

extension CoffeShopsResponseDTO {
    var toDomain: CoffeShops {
        .init(id: id, title: title, description: description, image: image, url: url)
    }
}

extension [CoffeShopsResponseDTO] {
    func toDomain() -> [CoffeShops] {
        map(\.toDomain)
    }
}
