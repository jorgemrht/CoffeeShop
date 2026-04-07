import Foundation
import Observation

public struct ErrorAlertPresentation: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let dismissButtonTitle: String

    public init(
        title: String,
        message: String?,
        dismissButtonTitle: String
    ) {
        self.title = title
        self.message = message
        self.dismissButtonTitle = dismissButtonTitle
    }
}

@MainActor
public protocol StoreErrorProtocol: AnyObject, Observable {
    var errorAlert: ErrorAlertPresentation? { get set }
}

@MainActor
public extension StoreErrorProtocol {
    func dismissErrorAlert() {
        errorAlert = nil
    }
}
