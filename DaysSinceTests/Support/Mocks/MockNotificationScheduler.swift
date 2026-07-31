@testable import DaysSince
import Foundation
import UserNotifications

/// In-memory `NotificationScheduling`. Every completion fires **synchronously**, so tests
/// can assert on the scheduler without waiting — note that `NotificationManager` still
/// hops to the main queue before publishing `pendingNotifications`, so assert on the mock
/// rather than on that property.
final class MockNotificationScheduler: NotificationScheduling {

    enum Call: Equatable {
        case add(String)
        case removeAll
        case removePending([String])
        case requestAuthorization
    }

    var authorization: NotificationAuthorization
    var authorizationGranted: Bool

    /// Mirrors the real center: `add` appends here, removals take entries out.
    private(set) var pending: [UNNotificationRequest] = []
    private(set) var added: [UNNotificationRequest] = []
    private(set) var calls: [Call] = []

    init(
        authorization: NotificationAuthorization = .authorized,
        authorizationGranted: Bool = true,
        pending: [UNNotificationRequest] = []
    ) {
        self.authorization = authorization
        self.authorizationGranted = authorizationGranted
        self.pending = pending
    }

    var addedIdentifiers: [String] { added.map(\.identifier) }
    var pendingIdentifiers: [String] { pending.map(\.identifier) }

    var removeAllCount: Int { calls.filter { $0 == .removeAll }.count }
    var authorizationRequestCount: Int { calls.filter { $0 == .requestAuthorization }.count }

    var removedIdentifiers: [[String]] {
        calls.compactMap {
            guard case let .removePending(identifiers) = $0 else { return nil }
            return identifiers
        }
    }

    // MARK: - NotificationScheduling

    func add(_ request: UNNotificationRequest) {
        calls.append(.add(request.identifier))
        added.append(request)
        pending.append(request)
    }

    func removeAllPending() {
        calls.append(.removeAll)
        pending.removeAll()
    }

    func removePending(identifiers: [String]) {
        calls.append(.removePending(identifiers))
        pending.removeAll { identifiers.contains($0.identifier) }
    }

    func pendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        completion(pending)
    }

    func authorizationStatus(completion: @escaping (NotificationAuthorization) -> Void) {
        completion(authorization)
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        calls.append(.requestAuthorization)
        authorization = authorizationGranted ? .authorized : .denied
        completion(authorizationGranted)
    }

    /// A stand-in pending request, for seeding `pending` without going through the manager.
    static func request(identifier: String) -> UNNotificationRequest {
        UNNotificationRequest(identifier: identifier, content: UNMutableNotificationContent(), trigger: nil)
    }
}
