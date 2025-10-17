//
//  StoreManager.swift
//  DaysSince
//
//  Created by Victoria Petrova on 25/08/2025.
//

import Foundation
import StoreKit
import SwiftUI

enum StoreManagerError: Error {
    case failedVerification
}

enum IAP {
    /// REPLACE with your real product ID from App Store Connect
    static let proProductID = "ds_399_lifetime"
}

@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var proProduct: Product?
    @Published private(set) var isPurchasing: Bool = false
    @Published var purchaseErrorMessage: String?

//    @AppStorage("hasProAccess") var hasProAccess: Bool = false

    private var updatesTask: Task<Void, Never>?
    /// Let the Entitlements layer know it should recompute when something changes.
    var onEntitlementPotentiallyChanged: (() -> Void)?
    var proDisplayPrice: String? { proProduct?.displayPrice }

    init() {
        updatesTask = listenForTransactions()
        Task {
            await requestProducts()
            await refreshEntitlements()
            onEntitlementPotentiallyChanged?()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func requestProducts() async {
        do {
            let products = try await Product.products(for: [IAP.proProductID])
            proProduct = products.first(where: { $0.id == [IAP.proProductID].first })
        } catch {
            purchaseErrorMessage = "Failed to load products. Please try again later."
            print("Product request error: \(error)")
        }
    }

    func purchasePro(inOnboarding: Bool = false) async {
        Analytics.send(.proStartPurchase)
        
        guard let product = proProduct else {
            await requestProducts()
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                if [IAP.proProductID].contains(transaction.productID) && transaction.revocationDate == nil {
//                    hasProAccess = true
                    onEntitlementPotentiallyChanged?()

                    Analytics.send(.proPurchased)
                    if inOnboarding {
                        Analytics.send(.proPurchasedInOnboarding)
                    }
                }
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseErrorMessage = (error as NSError).localizedDescription
            print("Purchase error: \(error)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            onEntitlementPotentiallyChanged?()
        } catch {
            purchaseErrorMessage = "Restore failed. Please try again."
            print("Restore error: \(error)")
        }
    }

    func refreshEntitlements() async {
//        var hasPro = false
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            if [IAP.proProductID].contains(transaction.productID),
               transaction.revocationDate == nil {
//                hasPro = true
                onEntitlementPotentiallyChanged?()
            }
        }
//        hasProAccess = hasPro
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified:
            throw StoreManagerError.failedVerification
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .medium) { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(update)
                    if [IAP.proProductID].contains(transaction.productID),
                       transaction.revocationDate == nil {
                        await MainActor.run {
//                            self.hasProAccess = true
                            self.onEntitlementPotentiallyChanged?()
                        }
                    }
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.purchaseErrorMessage = "Transaction verification failed."
                    }
                }
            }
        }
    }
}
