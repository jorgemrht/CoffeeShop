import Foundation

public protocol DiagnosticsRepository: Sendable {
    /// Sends all recent logs from OSLogStore (last hour) to support backend
    /// Use this for manual diagnostics when user reports a problem via UI
    func sendLogsToSupport() async throws
}
