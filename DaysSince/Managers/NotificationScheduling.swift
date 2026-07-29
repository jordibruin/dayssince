//
//  NotificationScheduling.swift
//  DaysSince
//

import Foundation
import UserNotifications

/// The authorization states the app reacts to. `UNNotificationSettings` is not
/// constructible outside the system, so the protocol reports this instead.
enum NotificationAuthorization {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    init(_ status: UNAuthorizationStatus) {
        switch status {
        case .authorized: self = .authorized
        case .provisional: self = .provisional
        case .ephemeral: self = .ephemeral
        case .notDetermined: self = .notDetermined
        default: self = .denied
        }
    }
}

/// The slice of `UNUserNotificationCenter` that `NotificationManager` uses.
protocol NotificationScheduling {
    func add(_ request: UNNotificationRequest)
    func removeAllPending()
    func removePending(identifiers: [String])
    func pendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void)
    func authorizationStatus(completion: @escaping (NotificationAuthorization) -> Void)
    func requestAuthorization(completion: @escaping (Bool) -> Void)
}

struct UserNotificationCenterScheduler: NotificationScheduling {

    private let center = UNUserNotificationCenter.current()

    func add(_ request: UNNotificationRequest) {
        center.add(request)
    }

    func removeAllPending() {
        center.removeAllPendingNotificationRequests()
    }

    func removePending(identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func pendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests(completionHandler: completion)
    }

    func authorizationStatus(completion: @escaping (NotificationAuthorization) -> Void) {
        center.getNotificationSettings { completion(NotificationAuthorization($0.authorizationStatus)) }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in completion(granted) }
    }
}
