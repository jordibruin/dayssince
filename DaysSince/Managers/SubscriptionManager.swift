//
//  SubscriptionManager.swift
//  DaysSince
//
//  Created by Victoria Petrova on 28/03/2026.
//

import StoreKit
import SwiftUI

class SubscriptionManager: ObservableObject {
    static let productIDs: [String] = [
        "dayssince.weekly",
        "dayssince.monthly",
        "dayssince.annual"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var isEligibleForIntro: Bool = false
    @Published private(set) var activeTransaction: StoreKit.Transaction?

    private var transactionListener: Task<Void, Never>?
    private let sharedDefaults = UserDefaults(suiteName: "group.goodsnooze.dayssince")

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            await MainActor.run {
                self.products = storeProducts.sorted { $0.price < $1.price }
            }
            await checkIntroEligibility()
        } catch {
            print("[SubscriptionManager] Failed to load products: \(error)")
        }
    }

    private func checkIntroEligibility() async {
        guard let weekly = product(for: "dayssince.weekly"),
              let subscription = weekly.subscription else { return }

        let eligible = await subscription.isEligibleForIntroOffer

        await MainActor.run {
            self.isEligibleForIntro = eligible
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            sendPurchaseNotification(for: product)
            await updateSubscriptionStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var hasActiveEntitlement = false
        var latest: StoreKit.Transaction?

        for await result in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                hasActiveEntitlement = true
                latest = transaction
            }
        }

        await MainActor.run {
            self.isSubscribed = hasActiveEntitlement
            self.activeTransaction = latest
            self.sharedDefaults?.set(hasActiveEntitlement, forKey: "dayssince_subscribed")
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await transaction.finish()
                    await self?.updateSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    // MARK: - Product Helpers

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    // MARK: - Ntfy Notifications

    private static let ntfyTopic = "https://ntfy.sh/dayssince-kahwn82"

    func sendPurchaseNotification(for product: Product) {
        sendNtfy(
            title: "New Subscription",
            body: "\(product.displayName) — \(product.displayPrice)"
        )
    }

    static func sendNewUserNotification() {
        sendNtfy(title: "New User", body: "Someone just opened Days Since for the first time")
    }

    private func sendNtfy(title: String, body: String) {
        Self.sendNtfy(title: title, body: body)
    }

    private static func sendNtfy(title: String, body: String) {
        guard let url = URL(string: ntfyTopic) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue(title, forHTTPHeaderField: "Title")
        request.setValue("DaysSince", forHTTPHeaderField: "Tags")
        URLSession.shared.dataTask(with: request).resume()
    }
}
