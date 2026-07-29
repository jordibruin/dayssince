//
//  CategoryStore.swift
//  DaysSince
//

import Defaults
import Foundation

/// Read/write access to the canonical category list.
///
/// The app-wide implementation is backed by `Defaults[.categories]`; tests inject a
/// store bound to an isolated `UserDefaults` suite so they never touch `.standard`.
protocol CategoryStoring {
    var categories: [Category] { get set }
}

enum CategoryStore {
    /// The UserDefaults key. Shared by `Defaults.Keys.categories` and the per-suite keys
    /// built below, so the `@Default(.categories)` view sites and injected stores agree.
    static let key = "categories"
}

struct DefaultsCategoryStore: CategoryStoring {
    private let key: Defaults.Key<[Category]>

    /// Uses the shared `Defaults.Keys.categories` key on `UserDefaults.standard`.
    init() {
        key = .categories
    }

    /// A key bound to `suite`. `Defaults.Key` binds its suite permanently at init,
    /// so isolation means building a new key rather than mutating a shared one.
    init(suite: UserDefaults) {
        key = Defaults.Key<[Category]>(CategoryStore.key, default: Category.builtInDefaults, suite: suite)
    }

    var categories: [Category] {
        get { Defaults[key] }
        nonmutating set { Defaults[key] = newValue }
    }
}
