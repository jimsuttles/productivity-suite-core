import Foundation
import Testing
@testable import ProductivitySuiteCore

struct SuiteHandoffPayloadTests {
    @Test("A v1 payload round-trips through the canonical codec")
    func roundTrip() throws {
        let payload = try makePayload()
        let data = try SuiteHandoffCodec.encode(payload)
        #expect(try SuiteHandoffCodec.decode(data) == payload)
    }

    @Test("The codec emits and accepts ISO-8601 dates")
    func iso8601DateCompatibility() throws {
        let data = try SuiteHandoffCodec.encode(makePayload())
        let object = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(object["createdAt"] as? String == "2025-03-04T12:34:56Z")
    }

    @Test("An existing Sprint 03 v1 JSON payload decodes without schema changes")
    func sprint03CompatibilityFixture() throws {
        let fixture = """
        {
          "id": "A5E9A66B-104A-4D12-8718-8D37826E2273",
          "version": 1,
          "sourceApp": "quickcapture",
          "destinationApp": "todaylist",
          "createdAt": "2025-03-04T12:34:56Z",
          "title": "Review project notes",
          "notes": "Captured before standup",
          "metadata": {
            "sourceList": "Inbox",
            "futureCompatibleKey": "preserved"
          }
        }
        """
        let data = try #require(fixture.data(using: .utf8))
        let payload = try SuiteHandoffCodec.decode(data)

        #expect(payload.version == 1)
        #expect(payload.sourceApp == .quickCapture)
        #expect(payload.destinationApp == .todayList)
        #expect(payload.metadata["futureCompatibleKey"] == "preserved")
    }

    @Test("Invalid JSON is reported as an invalid payload")
    func invalidPayload() {
        #expect(throws: SuiteHandoffCoreError.invalidPayload) {
            try SuiteHandoffCodec.decode(Data("not-json".utf8))
        }
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
