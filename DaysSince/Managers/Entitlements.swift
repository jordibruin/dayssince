//
//  Entitlements.swift
//  DaysSince
//
//  Created by Victoria Petrova on 17/10/2025.
//

import SwiftUI
import Foundation
import StoreKit

enum ProEntitlement: Equatable { case none, lifetime }

@MainActor
final class Entitlements: ObservableObject {
    @Published private(set) var isPro: Bool = false
    private unowned let store: StoreManager

    @AppStorage("cached_isPro") private var cachedIsPro: Bool = false

    init(store: StoreManager) {
        self.store = store
        self.isPro = cachedIsPro
        Task { await refresh() }
        store.onEntitlementPotentiallyChanged = { [weak self] in
            Task { await self?.refresh() }
        }
    }

    func refresh() async {
        var lifetime = false
        for await ent in Transaction.currentEntitlements {
            guard case .verified(let txn) = ent else { continue }
            if txn.productID == IAP.proProductID, txn.revocationDate == nil {
                lifetime = true
            }
        }
        isPro = lifetime
        cachedIsPro = lifetime
    }
}

enum Limits {
    static let freeEventLimit = 10
    static let freeCategoryLimit = 5
}

extension Entitlements {
    func canCreateNewEvent(currentCount: Int) -> Bool {
        isPro || currentCount < Limits.freeEventLimit
    }
    
    func canCreateNewCategory(currentCount: Int) -> Bool {
        isPro || currentCount < Limits.freeCategoryLimit
    }
}
