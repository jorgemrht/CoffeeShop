@MainActor
public protocol NavigationRouter: AnyObject {
    associatedtype Route: Sendable & Hashable
    var path: [Route] { get set }
}

@MainActor
public protocol SheetNavigationRouter: AnyObject {
    associatedtype Sheet: Identifiable & Sendable
    var presentedSheet: Sheet? { get set }
}

public extension NavigationRouter {
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func replaceStack(with route: Route) {
        path = [route]
    }
}

public extension SheetNavigationRouter {
    func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    func dismiss() {
        presentedSheet = nil
    }
}
