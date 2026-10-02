import Foundation

public enum SuiteHandoffCodec {
    public static func encode(_ payload: SuiteHandoffPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(payload)
    }

    public static func decode(_ data: Data) throws -> SuiteHandoffPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(SuiteHandoffPayload.self, from: data)
        } catch {
            throw SuiteHandoffCoreError.invalidPayload
        }
    }
}
