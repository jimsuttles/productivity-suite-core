import Foundation

public enum SuiteHandoffURL {
    public static func makeURL(
        destination: SuiteApp,
        handoffID: UUID,
        version: Int = SuiteHandoffConstants.schemaVersion
    ) throws -> URL {
        guard let scheme = scheme(for: destination), version > 0 else {
            throw SuiteHandoffCoreError.invalidDestinationScheme
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = "v\(version)"
        components.path = "/handoff/\(handoffID.uuidString)"

        guard let url = components.url else {
            throw SuiteHandoffCoreError.invalidDestinationScheme
        }
        return url
    }

    private static func scheme(for destination: SuiteApp) -> String? {
        switch destination {
        case .quickCapture: "quickcapture"
        case .todayList: "todaylist"
        case .top3: "top3"
        case .waitingFor: "waitingfor"
        case .dailyDecision: nil
        }
    }
}
