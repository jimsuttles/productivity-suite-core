import Foundation
import Testing
@testable import ProductivitySuiteCore

struct SuiteAppTests {
    @Test("Suite app raw values preserve the existing identifiers")
    func rawValues() {
        #expect(SuiteApp.quickCapture.rawValue == "quickcapture")
        #expect(SuiteApp.todayList.rawValue == "todaylist")
        #expect(SuiteApp.top3.rawValue == "top3")
        #expect(SuiteApp.waitingFor.rawValue == "waitingfor")
        #expect(SuiteApp.dailyDecision.rawValue == "dailydecision")
    }

    @Test(
        "Suite app identifiers decode",
        arguments: [
            ("quickCapture", SuiteApp.quickCapture),
            ("todayList", SuiteApp.todayList),
            ("quickcapture", SuiteApp.quickCapture),
            ("todaylist", SuiteApp.todayList)
        ]
    )
    func identifiersDecode(identifier: String, expectedApp: SuiteApp) throws {
        let data = try #require("\"\(identifier)\"".data(using: .utf8))
        #expect(try JSONDecoder().decode(SuiteApp.self, from: data) == expectedApp)
    }

    @Test(
        "Suite apps encode using canonical lowercase identifiers",
        arguments: [
            (SuiteApp.quickCapture, "\"quickcapture\""),
            (SuiteApp.todayList, "\"todaylist\"")
        ]
    )
    func encodingUsesCanonicalIdentifier(app: SuiteApp, expectedJSON: String) throws {
        let data = try JSONEncoder().encode(app)
        #expect(String(decoding: data, as: UTF8.self) == expectedJSON)
    }
}
