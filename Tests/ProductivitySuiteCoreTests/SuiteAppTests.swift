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
}
