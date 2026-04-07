import Domain

public struct CoffeeShopsResponseDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let image: String
    let url: String?
}

extension CoffeeShopsResponseDTO {
    func toDomain() throws -> CoffeeShops {
        guard let id = Int(id) else {
            throw APIError.decodingFailed(CoffeeShopsResponseMappingError.invalidID(self.id))
        }

        return .init(id: id, title: title, description: description, image: image, url: url)
    }
}

extension [CoffeeShopsResponseDTO] {
    func toDomain() throws -> [CoffeeShops] {
        try map { try $0.toDomain() }
    }
}

private enum CoffeeShopsResponseMappingError: Error {
    case invalidID(String)
}
