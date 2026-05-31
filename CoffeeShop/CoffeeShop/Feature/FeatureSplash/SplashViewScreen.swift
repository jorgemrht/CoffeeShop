import SwiftUI

public struct SplashViewScreen: View {

    @State private var opacity: Double = 0
    @State private var splashStore = SplashStore()
    private let onFinish: @MainActor (SplashDestination) -> Void

    public init(onFinish: @escaping @MainActor (SplashDestination) -> Void = { _ in }) {
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

            guard let destination = await splashStore.nextDestination() else {
                return
            }

            onFinish(destination)
        }
    }
}

#if DEBUG
#Preview {
    SplashViewScreen()
        .withPreviewEnvironment(root: .splash)
}
#endif
