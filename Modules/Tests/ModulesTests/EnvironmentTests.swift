import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - Environment Tests

struct EnvironmentTests {

    @Test func environmentStagingHasCorrectBaseURL() {
        // Given: Staging environment
        let environment = Environment.staging

        // When: Accessing baseURL
        let url = environment.baseURL

        // Then: Should return staging URL
        #expect(url.absoluteString == "https://staging.api.myapp.com")
    }

    @Test func environmentProductionHasCorrectBaseURL() {
        // Given: Production environment
        let environment = Environment.production

        // When: Accessing baseURL
        let url = environment.baseURL

        // Then: Should return production URL
        #expect(url.absoluteString == "https://api.myapp.com")
    }

    @Test func environmentStagingHasCorrectSupportLogsURL() {
        // Given: Staging environment
        let environment = Environment.staging

        // When: Accessing supportLogsURL
        let url = environment.supportLogsURL

        // Then: Should return staging logs URL
        #expect(url.absoluteString == "https://staging.api.myapp.com/support/logs")
    }

    @Test func environmentProductionHasCorrectSupportLogsURL() {
        // Given: Production environment
        let environment = Environment.production

        // When: Accessing supportLogsURL
        let url = environment.supportLogsURL

        // Then: Should return production logs URL
        #expect(url.absoluteString == "https://api.myapp.com/support/logs")
    }

    @Test func environmentCurrentReturnsValidEnvironment() {
        // Given: Current environment
        let current = Environment.current

        // When: Checking which environment
        // Then: Should be either staging or production
        #expect(current == .staging || current == .production)
    }

    @Test func environmentURLsAreValid() {
        // Given: Both environments
        let environments: [Environment] = [.staging, .production]

        // When/Then: All URLs should be valid
        for environment in environments {
            let baseURL = environment.baseURL
            let logsURL = environment.supportLogsURL

            #expect(baseURL.scheme == "https")
            #expect(logsURL.scheme == "https")
            #expect(!baseURL.absoluteString.isEmpty)
            #expect(!logsURL.absoluteString.isEmpty)
        }
    }

    @Test func environmentBaseURLsUseSameHost() {
        // Given: Staging and production environments
        let staging = Environment.staging
        let production = Environment.production

        // When: Comparing hosts
        // Then: Should have different hosts
        #expect(staging.baseURL.host != production.baseURL.host)
        #expect(staging.baseURL.host == "staging.api.myapp.com")
        #expect(production.baseURL.host == "api.myapp.com")
    }

    @Test func environmentURLsUseHTTPS() {
        // Given: All environments
        let environments: [Environment] = [.staging, .production]

        // When/Then: All URLs should use HTTPS
        for environment in environments {
            #expect(environment.baseURL.scheme == "https")
            #expect(environment.supportLogsURL.scheme == "https")
        }
    }
}
