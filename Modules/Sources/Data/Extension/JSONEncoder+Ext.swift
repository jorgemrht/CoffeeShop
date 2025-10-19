import Foundation

public extension JSONEncoder {
    static func apiDefaultJSONEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }
}
