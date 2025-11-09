import SwiftUI
import SharedCore

public struct SplashViewScreen: View {

    @Environment(AppState.self) private var appState

    @State private var opacity: Double = 0

    public init() {}

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Text("Splash")
                .font(.largeTitle)
                .fontWeight(.bold)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }

            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.transition(to: .auth)
                }
            }
        }
    }
}

#Preview {
    SplashViewScreen()
        .environment(AppState(root: .splash))
}
