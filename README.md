# Productivity Suite Core

A small Swift package for passing tasks between focused productivity apps without a backend.

The package defines a shared handoff format, deterministic identifiers, file transport through an Apple App Group, and deep links that carry a handoff ID rather than task text. [Today List](https://github.com/jimsuttles/today-list-mobile-app) is one consumer.

## Design

- **Shared contract:** a versioned, Codable payload with source, destination, creation time, title, notes, and extensible metadata.
- **Stable identity:** SHA-256-derived identifiers let callers reproduce a handoff ID from the source app, source entity, and destination.
- **Local transport:** JSON payloads move from `Handoffs/Pending` to `Handoffs/Completed` in a shared container.
- **Completion tracking:** repeated completion returns the existing completed file; a completed record prevents another pending write with that ID.
- **Content-free routes:** URLs such as `todaylist://v1/handoff/<UUID>` reference payloads without embedding titles or notes.
- **Compatibility:** the decoder accepts legacy `quickCapture` and `todayList` identifiers while encoding canonical lowercase identifiers.

The package handles transport. Receiving apps remain responsible for validating schema versions and destinations, importing records, and preventing duplicate application-level effects. This is not a cross-process transaction or an exactly-once delivery guarantee. Payload files contain task content; the URL design does not encrypt them.

## Requirements and integration

- Swift 6.0 toolchain (Xcode 16 or later on macOS).
- Package deployment targets: iOS 17 and macOS 14.
- No external package dependencies.

Add this repository through Xcode's package dependencies and select the `ProductivitySuiteCore` library. Consumers currently tracking `main` can pin a reviewed commit for reproducible builds.

For cross-app use, participating apps must have matching App Group entitlements and registered destination URL schemes. The default group is `group.com.4ctech.productivitysuite`; use an App Group provisioned for your own team when adapting the package.

## Example

This example uses an explicit temporary container so the file lifecycle can be explored without signing or App Group setup:

```swift
import Foundation
import ProductivitySuiteCore

func demonstrateHandoff() throws {
    let container = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: container) }

    let transport = SuiteHandoffTransport(containerURL: container)
    let id = SuiteHandoffID.generate(
        sourceApp: .quickCapture,
        sourceEntityID: "example-capture-001",
        destinationApp: .todayList
    )
    let payload = SuiteHandoffPayload(
        id: id,
        sourceApp: .quickCapture,
        destinationApp: .todayList,
        createdAt: Date(),
        title: "Review project notes"
    )

    try transport.writePending(payload)
    let route = try SuiteHandoffURL.makeURL(
        destination: .todayList,
        handoffID: id
    )
    let received = try transport.loadPending(handoffID: id)
    print(route, received.title)

    // A real receiver validates and durably imports before completing.
    try transport.complete(handoffID: id)
}

try demonstrateHandoff()
```

In a signed app with the shared entitlement, use `try SuiteHandoffTransport()` to resolve the default App Group container. Opening routes and handling incoming URLs belong to the consuming app.

## Source map

| Component | Responsibility |
| --- | --- |
| [SuiteApp](Sources/ProductivitySuiteCore/SuiteApp.swift) | App identifiers and legacy decoding |
| [SuiteHandoffPayload](Sources/ProductivitySuiteCore/SuiteHandoffPayload.swift) | Shared payload model |
| [SuiteHandoffCodec](Sources/ProductivitySuiteCore/SuiteHandoffCodec.swift) | JSON encoding and ISO-8601 dates |
| [SuiteHandoffID](Sources/ProductivitySuiteCore/SuiteHandoffID.swift) | Deterministic identifier generation |
| [SuiteHandoffTransport](Sources/ProductivitySuiteCore/SuiteHandoffTransport.swift) | Pending/completed file lifecycle |
| [SuiteHandoffURL](Sources/ProductivitySuiteCore/SuiteHandoffURL.swift) | Destination routes |

## Tests

Run on macOS with the Swift 6 toolchain:

```sh
swift test
```

[Swift Testing suites](Tests/ProductivitySuiteCoreTests) cover identifier stability, payload compatibility, malformed data, content-free URLs, and pending/completed transport behavior. File transport tests use temporary containers; they do not establish signed, cross-app device behavior.

## Development

See [AI development workflow](AI_DEVELOPMENT_WORKFLOW.md) for implementation, review, and local validation responsibilities.
