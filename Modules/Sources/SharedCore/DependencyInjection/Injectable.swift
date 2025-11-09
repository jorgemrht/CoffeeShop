import Foundation

@MainActor
public protocol Injectable: AnyObject {
    static func resolve(from container: DependencyContainer) -> Self
}
