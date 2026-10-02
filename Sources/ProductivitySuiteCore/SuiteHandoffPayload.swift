import Foundation

public struct SuiteHandoffPayload: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let version: Int
    public let sourceApp: SuiteApp
    public let destinationApp: SuiteApp
    public let createdAt: Date
    public let title: String
    public let notes: String?
    public let metadata: [String: String]

    public init(
        id: UUID,
        version: Int = SuiteHandoffConstants.schemaVersion,
        sourceApp: SuiteApp,
        destinationApp: SuiteApp,
        createdAt: Date,
        title: String,
        notes: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.version = version
        self.sourceApp = sourceApp
        self.destinationApp = destinationApp
        self.createdAt = createdAt
        self.title = title
        self.notes = notes
        self.metadata = metadata
    }
}
