import SwiftUI
import Data
import Domain
import Tracking
public struct PreviewHelper {
    public static var mockNetworkClient: NetworkClient {
        NetworkClient(
            baseURL: "https://mock.local",
            session: .shared,
            interceptors: [],
            bundleIdentifier: "com.preview"
        )
    }
}
