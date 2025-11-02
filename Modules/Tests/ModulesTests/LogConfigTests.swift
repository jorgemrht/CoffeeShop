import Testing
import Foundation
@testable import Domain
@testable import Data
@testable import Tracking

// MARK: - LogConfig Tests

struct LogConfigTests {

    @Test func logConfigCreatesWithEndpoint() {
        // Given: A URL endpoint
        let endpoint = URL(string: "https://logs.example.com/api")!

        // When: Creating LogConfig
        let config = LogConfig(endpoint: endpoint)

        // Then: Should store endpoint correctly
        #expect(config.endpoint == endpoint)
    }

    @Test func logConfigStagingHasCorrectEndpoint() {
        // Given: Staging log config
        let config = LogConfig.staging

        // When: Accessing endpoint
        let endpoint = config.endpoint

        // Then: Should return staging logs endpoint
        #expect(endpoint.absoluteString == "https://staging.api.myapp.com/logs")
    }

    @Test func logConfigProductionHasCorrectEndpoint() {
        // Given: Production log config
        let config = LogConfig.production

        // When: Accessing endpoint
        let endpoint = config.endpoint

        // Then: Should return production logs endpoint
        #expect(endpoint.absoluteString == "https://api.myapp.com/logs")
    }

    @Test func logConfigCurrentReturnsValidConfiguration() {
        // Given: Current log config
        let current = LogConfig.current

        // When: Checking endpoint
        // Then: Should have a valid HTTPS endpoint
        #expect(current.endpoint.scheme == "https")
        #expect(!current.endpoint.absoluteString.isEmpty)
    }

    @Test func logConfigStagingAndProductionHaveDifferentEndpoints() {
        // Given: Staging and production configs
        let staging = LogConfig.staging
        let production = LogConfig.production

        // When: Comparing endpoints
        // Then: Should have different endpoints
        #expect(staging.endpoint != production.endpoint)
        #expect(staging.endpoint.absoluteString.contains("staging"))
        #expect(!production.endpoint.absoluteString.contains("staging"))
    }

    @Test func logConfigEndpointsUseHTTPS() {
        // Given: All log configs
        let configs = [LogConfig.staging, LogConfig.production, LogConfig.current]

        // When/Then: All should use HTTPS
        for config in configs {
            #expect(config.endpoint.scheme == "https")
        }
    }

    @Test func logConfigIsSendable() {
        // Given: A LogConfig instance
        let config = LogConfig.staging

        // When: Checking Sendable conformance (compile-time)
        // Then: Should compile (LogConfig conforms to Sendable)
        let _: any Sendable = config
        #expect(config.endpoint.absoluteString.contains("staging"))
    }

    @Test func logConfigCanBeUsedAcrossActorBoundaries() async {
        // Given: A LogConfig
        let config = LogConfig.production

        // When: Using in async context
        let endpoint = await Task { config.endpoint }.value

        // Then: Should work across concurrency boundaries
        #expect(endpoint.absoluteString == "https://api.myapp.com/logs")
    }
}
