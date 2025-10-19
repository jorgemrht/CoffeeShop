import Foundation

public extension JSONDecoder {
    static func apiDefaultJSONDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }
}
