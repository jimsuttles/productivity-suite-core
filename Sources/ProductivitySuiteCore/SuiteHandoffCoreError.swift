public enum SuiteHandoffCoreError: Error, Equatable, Sendable {
    case appGroupUnavailable
    case payloadMissing
    case invalidPayload
    case alreadyCompleted
    case fileOperationFailed
    case invalidDestinationScheme
}
