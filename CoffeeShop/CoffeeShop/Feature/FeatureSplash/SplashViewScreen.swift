import SwiftUI

public struct SplashViewScreen: View {

    @State private var opacity: Double = 0
    private let onFinish: @MainActor (Destination) -> Void

    public init(onFinish: @escaping @MainActor (Destination) -> Void = { _ in }) {
        self.onFinish = onFinish
    }

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Text("Splash")
                .font(.largeTitle)
                .fontWeight(.bold)
                .opacity(opacity)
        }
        .task {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }

            try? await Task.sleep(for: .seconds(2))
            onFinish(.auth)
        }
    }
}

public extension SplashViewScreen {
    nonisolated enum Destination: Sendable {
        case auth
        case main
    }
}

#Preview {
    SplashViewScreen()
        .withPreviewEnvironment(root: .splash)
}
