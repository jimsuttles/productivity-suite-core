public enum SuiteApp: String, Codable, CaseIterable, Sendable {
    case quickCapture = "quickcapture"
    case todayList = "todaylist"
    case top3 = "top3"
    case waitingFor = "waitingfor"
    case dailyDecision = "dailydecision"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)

        switch identifier {
        case "quickCapture":
            self = .quickCapture
        case "todayList":
            self = .todayList
        default:
            guard let app = SuiteApp(rawValue: identifier) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown suite app identifier: \(identifier)"
                )
            }
            self = app
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
