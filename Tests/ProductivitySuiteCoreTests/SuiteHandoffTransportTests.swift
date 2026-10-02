import Foundation
import Testing
@testable import ProductivitySuiteCore

struct SuiteHandoffTransportTests {
    @Test("Pending writes load the same payload")
    func pendingWriteAndLoadRoundTrip() throws {
        let context = try makeContext()
        defer { context.remove() }
        let payload = try makePayload()
        try context.transport.writePending(payload)

        #expect(try context.transport.loadPending(handoffID: payload.id) == payload)
    }

    @Test("Completion moves a payload and updates existence")
    func pendingToCompletedMove() throws {
        let context = try makeContext()
        defer { context.remove() }
        let payload = try makePayload()
        try context.transport.writePending(payload)

        let completedURL = try context.transport.complete(handoffID: payload.id)

        #expect(completedURL == context.transport.completedURL(for: payload.id))
        #expect(context.transport.isCompleted(handoffID: payload.id))
        #expect(!FileManager.default.fileExists(
            atPath: context.transport.pendingURL(for: payload.id).path
        ))
    }

    @Test("Repeated completion is idempotent")
    func repeatedCompletion() throws {
        let context = try makeContext()
        defer { context.remove() }
        let payload = try makePayload()
        try context.transport.writePending(payload)

        let firstURL = try context.transport.complete(handoffID: payload.id)
        let secondURL = try context.transport.complete(handoffID: payload.id)

        #expect(firstURL == secondURL)
        #expect(context.transport.isCompleted(handoffID: payload.id))
    }

    @Test("A completed record blocks pending re-creation")
    func completedRecordBlocksRecreation() throws {
        let context = try makeContext()
        defer { context.remove() }
        let payload = try makePayload()
        try context.transport.writePending(payload)
        try context.transport.complete(handoffID: payload.id)

        #expect(throws: SuiteHandoffCoreError.alreadyCompleted) {
            try context.transport.writePending(payload)
        }
    }

    @Test("A missing pending payload reports payloadMissing")
    func missingPayload() throws {
        let context = try makeContext()
        defer { context.remove() }

        #expect(throws: SuiteHandoffCoreError.payloadMissing) {
            try context.transport.loadPending(handoffID: UUID())
        }
        #expect(throws: SuiteHandoffCoreError.payloadMissing) {
            try context.transport.complete(handoffID: UUID())
        }
    }

    @Test("Malformed pending data reports invalidPayload")
    func malformedPayload() throws {
        let context = try makeContext()
        defer { context.remove() }
        let id = UUID()
        let url = context.transport.pendingURL(for: id)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: url, options: .atomic)

        #expect(throws: SuiteHandoffCoreError.invalidPayload) {
            try context.transport.loadPending(handoffID: id)
        }
    }

    private func makeContext() throws -> TestContext {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: rootURL,
            withIntermediateDirectories: true
        )
        return TestContext(
            rootURL: rootURL,
            transport: SuiteHandoffTransport(containerURL: rootURL)
        )
    }

    private func makePayload() throws -> SuiteHandoffPayload {
        SuiteHandoffPayload(
            id: try #require(
                UUID(uuidString: "A5E9A66B-104A-4D12-8718-8D37826E2273")
            ),
            sourceApp: .quickCapture,
            destinationApp: .todayList,
            createdAt: Date(timeIntervalSince1970: 1_741_091_696),
            title: "Review project notes",
            notes: "Captured before standup",
            metadata: ["sourceList": "Inbox"]
        )
    }
}

private struct TestContext {
    let rootURL: URL
    let transport: SuiteHandoffTransport

    func remove() {
        try? FileManager.default.removeItem(at: rootURL)
    }
}
