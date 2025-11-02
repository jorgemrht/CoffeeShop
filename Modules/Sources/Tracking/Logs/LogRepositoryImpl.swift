import Foundation
import Domain

public struct LogRepositoryImpl: Sendable {

    private let deviceInfo: DeviceInfo
    private let config: LogConfig
    private let session: URLSession

    public init(
        deviceInfo: DeviceInfo,
        config: LogConfig,
        session: URLSession = .shared
    ) {
        self.deviceInfo = deviceInfo
        self.config = config
        self.session = session
    }

    public func log(_ level: LogLevel, _ context: LogContext, error: Error?) async {
        let log = Log(
            deviceInfo: deviceInfo,
            level: level.rawValue,
            context: context.rawValue,
            errorDescription: error?.localizedDescription,
            timestamp: Date()
        )
        await sendLog(log)
    }

    private func sendLog(_ log: Log) async {
        do {
            var request = URLRequest(url: config.endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(log)

            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                #if DEBUG
                print("❌ Failed to send log: Invalid status code")
                #endif
                return
            }

            #if DEBUG
            print("✅ Log sent successfully")
            #endif

        } catch {
            #if DEBUG
            print("❌ Failed to send log: \(error.localizedDescription)")
            #endif
        }
    }
}
