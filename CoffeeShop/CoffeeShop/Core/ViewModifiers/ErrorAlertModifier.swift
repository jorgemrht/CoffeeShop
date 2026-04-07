import SwiftUI
import DesignSystem

public struct ErrorAlertModifier: ViewModifier {
    private let errorAlert: ErrorAlertPresentation?
    private let onDismiss: () -> Void

    public init(
        errorAlert: ErrorAlertPresentation?,
        onDismiss: @escaping () -> Void
    ) {
        self.errorAlert = errorAlert
        self.onDismiss = onDismiss
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                errorAlert?.title ?? "",
                isPresented: isPresented,
                presenting: errorAlert
            ) { alert in
                Button(alert.dismissButtonTitle) {
                    onDismiss()
                }
            } message: { alert in
                if let message = alert.message {
                    Text(message)
                }
            }
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: { errorAlert != nil },
            set: { isPresented in
                if !isPresented {
                    onDismiss()
                }
            }
        )
    }
}

extension View {
    func errorAlertView(
        _ errorAlert: ErrorAlertPresentation?,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            ErrorAlertModifier(
                errorAlert: errorAlert,
                onDismiss: onDismiss
            )
        )
    }
}

