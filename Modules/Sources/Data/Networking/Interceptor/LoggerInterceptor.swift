import Foundation
import OSLog
import os.signpost

// Logger: https://developer.apple.com/documentation/os/logger
// OSSignposter: https://developer.apple.com/documentation/os/ossignposter
// Privacy: https://developer.apple.com/videos/play/wwdc2020/10168/
// Duration: https://developer.apple.com/documentation/swift/duration
// MetricKit: https://developer.apple.com/documentation/MetricKit
// TestFlight with logging profiles: https://developer.apple.com/documentation/os/logging/generating_log_archives_for_debugging
// Signposts also work in Release but are only activated when: The device is connected to Instruments or uses MetricKit to collect aggregate metrics
// Guidelines/#data-collection-and-storage: https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage

public struct LoggerInterceptor: RequestInterceptor {
    
    private let logger: Logger
    private let signposter: OSSignposter
    private let logLevel: LogLevel
    private let includeHeaders: Bool
    private let includeBody: Bool
    private let sensitiveHeaders: Set<String>
    private let maxBodySizeKB: Int

    public enum LogLevel: Int, Comparable, Sendable {
        case debug = 0
        case info = 1
        case error = 2

        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public init(
        subsystem: String?,
        category: String,
        logLevel: LogLevel = .info,
        includeHeaders: Bool = false,
        includeBody: Bool = false,
        sensitiveHeaders: Set<String> = ["authorization", "token", "api-key", "x-api-key", "cookie", "set-cookie"],
        maxBodySizeKB: Int = 64
    ) {
        self.logger = Logger(subsystem: subsystem ?? "none", category: category)
        self.signposter = OSSignposter(subsystem: subsystem ?? "none", category: category)
        self.logLevel = logLevel
        self.includeHeaders = includeHeaders
        self.includeBody = includeBody
        self.sensitiveHeaders = sensitiveHeaders
        self.maxBodySizeKB = maxBodySizeKB
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {

        let signpostID = signposter.makeSignpostID()

        let state = signposter.beginInterval(
            SignpostName.httpRequest,
            id: signpostID
        )

        defer {
            signposter.endInterval(SignpostName.httpRequest, state)
        }

        if logLevel <= .debug {
            logRequest(request)
        }

        let startTime = ContinuousClock.now

        do {
            let response = try await next(request, session)
            let duration = startTime.duration(to: .now)

            signposter.emitEvent(
                SignpostName.response,
                id: signpostID
            )

            if logLevel <= .info {
                logResponse(response, duration: duration)
            }

            return response

        } catch {
            let duration = startTime.duration(to: .now)

            signposter.emitEvent(
                SignpostName.error,
                id: signpostID
            )

            if logLevel <= .error {
                logError(request, error: error, duration: duration)
            }

            throw error
        }
    }

    private func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = sanitizedURLString(request.url)

        logger.debug("\(method, privacy: .public) \(url, privacy: .public)")

        if includeHeaders, let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            for (key, value) in headers {
                if isSensitiveHeader(key) {
                    logger.debug("  \(key, privacy: .public): <redacted>")
                } else {
                    logger.debug("  \(key, privacy: .public): \(value, privacy: .public)")
                }
            }
        }

        if includeBody, let body = request.httpBody {
            let isJSON = isJSONContent(request.allHTTPHeaderFields)
            logBodyData(body, label: "Request Body", isJSON: isJSON)
        }
    }

    private func logResponse(_ response: APIResponse, duration: Duration) {
        let method = response.request.httpMethod ?? "GET"
        let url = sanitizedURLString(response.request.url)
        let status = response.statusCode
        let durationMs = duration.milliseconds
        let bytesReceived = response.data.count
        let emoji = statusEmoji(for: status)
        let sizeFormatted = formatByteSize(bytesReceived)

        logger.info("\(emoji) \(method, privacy: .public) \(url, privacy: .public) → \(status) (\(durationMs)ms, \(sizeFormatted))")

        if logLevel == .debug {
            if includeHeaders {
                for (key, value) in response.response.allHeaderFields {
                    let keyStr = String(describing: key)
                    let valueStr = String(describing: value)

                    if isSensitiveHeader(keyStr) {
                        logger.debug("  \(keyStr, privacy: .public): <redacted>")
                    } else {
                        logger.debug("  \(keyStr, privacy: .public): \(valueStr, privacy: .public)")
                    }
                }
            }

            if includeBody, !response.data.isEmpty {
                let isJSON = isJSONContent(response.response.allHeaderFields)
                logBodyData(response.data, label: "Response Body", isJSON: isJSON)
            }
        }
    }

    private func logError(_ request: URLRequest, error: Error, duration: Duration) {
        let method = request.httpMethod ?? "GET"
        let url = sanitizedURLString(request.url)
        let durationMs = duration.milliseconds

        logger.error("❌ \(method, privacy: .public) \(url, privacy: .public) failed after \(durationMs)ms")

        if let apiError = error as? APIError {
            logger.error("  Error: \(String(describing: apiError), privacy: .public)")
        } else {
            logger.error("  Error: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Source: https://developer.apple.com/videos/play/wwdc2020/10168/
    private func sanitizedURLString(_ url: URL?) -> String {
        guard let url = url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "unknown"
        }

        components.query = nil
        components.fragment = nil

        return components.string ?? "unknown"
    }

    private func isSensitiveHeader(_ headerName: String) -> Bool {
        let lowercased = headerName.lowercased()
        return sensitiveHeaders.contains { lowercased.contains($0) }
    }
    
    private func isJSONContent(_ headers: [AnyHashable: Any]?) -> Bool {
        guard let contentType = headers?["Content-Type"] as? String else { return false }
        return contentType.lowercased().contains("application/json")
    }

    private func formatByteSize(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes)B"
        } else if bytes < 1024 * 1024 {
            let kb = Double(bytes) / 1024.0
            return String(format: "%.1fKB", kb)
        } else {
            let mb = Double(bytes) / (1024.0 * 1024.0)
            return String(format: "%.2fMB", mb)
        }
    }

    private func logBodyData(_ data: Data, label: String, isJSON: Bool) {
        let maxBytes = maxBodySizeKB * 1024
        let dataToLog = data.prefix(maxBytes)
        let wasTruncated = data.count > maxBytes

        if isJSON,
           let json = try? JSONSerialization.jsonObject(with: dataToLog),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {

            if wasTruncated {
                logger.debug("\(label): \(prettyString, privacy: .private) [TRUNCATED: \(data.count) bytes total]")
            } else {
                logger.debug("\(label): \(prettyString, privacy: .private)")
            }
        } else if let bodyString = String(data: dataToLog, encoding: .utf8) {
            if wasTruncated {
                logger.debug("\(label): \(bodyString, privacy: .private) [TRUNCATED: \(data.count) bytes total]")
            } else {
                logger.debug("\(label): \(bodyString, privacy: .private)")
            }
        } else {
            logger.debug("\(label): <\(data.count) bytes, binary data>")
        }
    }

    private func statusEmoji(for statusCode: Int) -> String {
        switch statusCode {
        case 200..<300: return "✅"  // Success
        case 300..<400: return "↩️"  // Redirect
        case 400..<500: return "⚠️"  // Client error
        case 500..<600: return "❌"  // Server error
        default: return "❓"         // Unknown
        }
    }
}

/// Source: https://developer.apple.com/documentation/swift/duration
/// Discussion: https://forums.swift.org/t/duration-api-best-practices/62345
private extension Duration {
    var milliseconds: Int {
        Int((self / .milliseconds(1)).rounded())
    }
}

extension LoggerInterceptor {
    private enum SignpostName {
        static let httpRequest: StaticString = "HTTP Request"
        static let response: StaticString = "Response"
        static let error: StaticString = "Error"
    }
}
