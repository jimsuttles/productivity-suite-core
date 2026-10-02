import Foundation

public struct SuiteHandoffTransport: Sendable {
    public let containerURL: URL

    public init(containerURL: URL) {
        self.containerURL = containerURL
    }

    public init(
        appGroupIdentifier: String = SuiteHandoffConstants.appGroupIdentifier,
        fileManager: FileManager = .default
    ) throws {
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            throw SuiteHandoffCoreError.appGroupUnavailable
        }
        self.containerURL = containerURL
    }

    public func pendingURL(for handoffID: UUID) -> URL {
        directoryURL(for: SuiteHandoffConstants.pendingDirectory)
            .appendingPathComponent(fileName(for: handoffID), isDirectory: false)
    }

    public func completedURL(for handoffID: UUID) -> URL {
        directoryURL(for: SuiteHandoffConstants.completedDirectory)
            .appendingPathComponent(fileName(for: handoffID), isDirectory: false)
    }

    public func writePending(_ payload: SuiteHandoffPayload) throws {
        let fileManager = FileManager.default
        let url = pendingURL(for: payload.id)

        guard !fileManager.fileExists(atPath: completedURL(for: payload.id).path) else {
            throw SuiteHandoffCoreError.alreadyCompleted
        }

        do {
            try fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try SuiteHandoffCodec.encode(payload).write(to: url, options: .atomic)
        } catch let error as SuiteHandoffCoreError {
            throw error
        } catch {
            throw SuiteHandoffCoreError.fileOperationFailed
        }
    }

    public func loadPending(handoffID: UUID) throws -> SuiteHandoffPayload {
        let url = pendingURL(for: handoffID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw SuiteHandoffCoreError.payloadMissing
        }

        do {
            return try SuiteHandoffCodec.decode(Data(contentsOf: url))
        } catch let error as SuiteHandoffCoreError {
            throw error
        } catch {
            throw SuiteHandoffCoreError.fileOperationFailed
        }
    }

    public func isCompleted(handoffID: UUID) -> Bool {
        FileManager.default.fileExists(atPath: completedURL(for: handoffID).path)
    }

    @discardableResult
    public func complete(handoffID: UUID) throws -> URL {
        let fileManager = FileManager.default
        let pendingURL = pendingURL(for: handoffID)
        let completedURL = completedURL(for: handoffID)

        if fileManager.fileExists(atPath: completedURL.path) {
            return completedURL
        }
        guard fileManager.fileExists(atPath: pendingURL.path) else {
            throw SuiteHandoffCoreError.payloadMissing
        }

        do {
            try fileManager.createDirectory(
                at: completedURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.moveItem(at: pendingURL, to: completedURL)
            return completedURL
        } catch {
            if fileManager.fileExists(atPath: completedURL.path) {
                return completedURL
            }
            throw SuiteHandoffCoreError.fileOperationFailed
        }
    }

    private func directoryURL(for relativePath: String) -> URL {
        relativePath.split(separator: "/").reduce(containerURL) { url, component in
            url.appendingPathComponent(String(component), isDirectory: true)
        }
    }

    private func fileName(for handoffID: UUID) -> String {
        "\(handoffID.uuidString).json"
    }
}
