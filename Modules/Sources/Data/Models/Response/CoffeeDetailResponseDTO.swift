import Domain

public struct CoffeeDetailResponseDTO: Decodable {
    public let id: Int
    public let name: String
    public let specialty: String
    public let summary: String
}

extension CoffeeDetailResponseDTO {
    func toDomain() -> CoffeeDetail {
        CoffeeDetail(
            id: id,
            name: name,
            specialty: specialty,
            summary: summary
        )
    }
}
