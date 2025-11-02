import Testing
import Foundation
@testable import Domain
@testable import Data

struct MockAppInfoProvider: AppInfoProvider {
    let appVersion: String
    let buildNumber: String
}
