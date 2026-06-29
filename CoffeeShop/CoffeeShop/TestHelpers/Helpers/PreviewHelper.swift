#if DEBUG
import SwiftUI
import Data
import Domain
import Macros

public struct PreviewHelper {
    public static var mockNetworkClient: NetworkClient {
        NetworkClient(
            baseURL: #URL("https://mock.local"),
            session: .shared,
            interceptors: [],
            subsystem: "com.preview"
        )
    }
}
#endif
