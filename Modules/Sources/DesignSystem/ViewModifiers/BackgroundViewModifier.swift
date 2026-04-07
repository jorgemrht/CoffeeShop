import SwiftUI

public struct BackgroundViewModifier: ViewModifier {
    public init() { }

    public func body(content: Content) -> some View {
        content
            .background {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    public func backgroundView() -> some View {
        modifier(BackgroundViewModifier())
    }
}
