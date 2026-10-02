import Foundation
import Testing
@testable import ProductivitySuiteCore

struct SuiteHandoffURLTests {
    @Test("A handoff URL contains only its opaque route")
    func opaqueRoute() throws {
        let id = try #require(
            UUID(uuidString: "A5E9A66B-104A-4D12-8718-8D37826E2273")
        )
        let url = try SuiteHandoffURL.makeURL(destination: .todayList, handoffID: id)

        #expect(url.absoluteString == "todaylist://v1/handoff/A5E9A66B-104A-4D12-8718-8D37826E2273")
    }

    @Test("A handoff URL never exposes source or user content")
    func excludesUserContent() throws {
        let sourceID = "private-source-123"
        let title = "Private title"
        let notes = "Private notes"
        let id = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: sourceID,
            destinationApp: .top3
        )
        let urlString = try SuiteHandoffURL.makeURL(
            destination: .top3,
            handoffID: id
        ).absoluteString

        #expect(!urlString.contains(sourceID))
        #expect(!urlString.contains(title))
        #expect(!urlString.contains(notes))
        #expect(urlString == "top3://v1/handoff/\(id.uuidString)")
    }

    @Test("A destination without a registered scheme is rejected")
    func invalidDestinationScheme() {
        #expect(throws: SuiteHandoffCoreError.invalidDestinationScheme) {
            try SuiteHandoffURL.makeURL(
                destination: .dailyDecision,
                handoffID: UUID()
            )
        }
    }
}
