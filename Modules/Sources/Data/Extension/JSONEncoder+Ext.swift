import Foundation

public extension JSONEncoder {
    static func encoderDefault() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
