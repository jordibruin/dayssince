import Testing

/// Umbrella for every suite that touches process-global state: `UserDefaults.standard`
/// (via `Defaults`/`@AppStorage`), `Analytics.sink`, or `SKTestSession`.
///
/// This covers suites that *fire* analytics as well as ones that install a spy: a
/// signal sent from a parallel suite lands in whichever spy is currently installed.
///
/// `.serialized` only serializes a suite against its own descendants, not against
/// sibling top-level suites — so global-state suites must be nested here (via
/// `extension GlobalStateSuite { @Suite struct ... }`) rather than declared top-level.
@Suite("Global state", .serialized)
struct GlobalStateSuite {}
