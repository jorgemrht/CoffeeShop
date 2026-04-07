import SwiftUI

public struct LoadingViewModifier: ViewModifier {
    private let isLoading: Bool

    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.12)
                            .ignoresSafeArea()

                        ProgressView()
                            .controlSize(.large)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Loading")
                }
            }
    }
}

extension View {
    public func loadingView(_ isLoading: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
