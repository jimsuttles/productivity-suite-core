import Foundation
import Testing
@testable import ProductivitySuiteCore

struct SuiteHandoffIDTests {
    @Test("A known Quick Capture identity produces a stable deterministic UUID")
    func quickCaptureDeterministicStability() throws {
        let first = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-123",
            destinationApp: .todayList
        )
        let second = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-123",
            destinationApp: .todayList
        )
        let expected = try #require(
            UUID(uuidString: "97FB7E9E-5D65-53B5-ADD0-B1603B41E231")
        )

        #expect(first == second)
        #expect(first == expected)
    }

    @Test("The existing Today List to Top 3 identity produces the exact compatible UUID")
    func todayListToTop3Compatibility() throws {
        let id = SuiteHandoffID.generate(
            sourceApp: .todayList,
            sourceEntityID: "task-123",
            destinationApp: .top3
        )
        let expected = try #require(
            UUID(uuidString: "3F6E0ED9-4EDF-5869-A989-254AF5979C30")
        )

        #expect(id == expected)
    }

    @Test("Changing the source entity ID changes the UUID")
    func sourceEntityChangesIdentity() {
        let first = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-123",
            destinationApp: .todayList
        )
        let second = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-456",
            destinationApp: .todayList
        )
        #expect(first != second)
    }

    @Test("Changing the destination changes the UUID")
    func destinationChangesIdentity() {
        let todayListID = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-123",
            destinationApp: .todayList
        )
        let top3ID = SuiteHandoffID.generate(
            sourceApp: .quickCapture,
            sourceEntityID: "capture-123",
            destinationApp: .top3
        )
        #expect(todayListID != top3ID)
    }
}
