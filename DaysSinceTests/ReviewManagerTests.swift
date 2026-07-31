@testable import DaysSince
import Foundation
import Testing

/// Pure tier: the once-per-version rule on its own, with no storage or StoreKit.
@Suite("ReviewManager.shouldPrompt")
struct ReviewManagerShouldPromptTests {

    @Test(
        "a prompt is due only for a version we have not asked about",
        arguments: [
            (String?("1.5"), "1.4", true),
            (String?("1.5"), "1.5", false),
            (String?("1.4"), "1.5", true), // a downgrade is still a different version
            (String?("1.0"), "1.0", false), // matches the default seed
            (String?(nil), "1.4", false), // unreadable bundle version
            (String?(nil), "1.0", false),
        ]
    )
    func shouldPrompt(currentVersion: String?, lastAskedVersion: String, expected: Bool) {
        #expect(
            ReviewManager.shouldPrompt(
                currentVersion: currentVersion,
                lastAskedVersion: lastAskedVersion
            ) == expected
        )
    }

    @Test("version comparison is exact, not numeric")
    func exactStringComparison() {
        #expect(ReviewManager.shouldPrompt(currentVersion: "1.10", lastAskedVersion: "1.1"))
        #expect(!ReviewManager.shouldPrompt(currentVersion: "1.10", lastAskedVersion: "1.10"))
    }
}

/// Global tier: a successful prompt fires `Analytics.send(.reviewPrompt)` through the
/// process-global `Analytics.sink`.
extension GlobalStateSuite {

    @Suite("ReviewManager prompting")
    struct ReviewManagerTests {

        private let isolated = IsolatedDefaults()

        /// Records presentation attempts and controls whether StoreKit "succeeded".
        private final class SpyPresenter {
            var result: Bool
            private(set) var attempts = 0

            init(result: Bool) { self.result = result }

            func present() -> Bool {
                attempts += 1
                return result
            }
        }

        private func makeManager(
            appVersion: String?,
            presenter: SpyPresenter
        ) -> ReviewManager {
            ReviewManager(
                defaults: isolated.defaults,
                appVersion: appVersion,
                presentReview: presenter.present
            )
        }

        private var storedVersion: String? {
            isolated.defaults.string(forKey: ReviewManager.lastAskedVersionKey)
        }

        // MARK: - Seed

        @Test("an untouched install reports the seed version")
        func defaultLastAskedVersion() {
            let manager = makeManager(appVersion: "1.5", presenter: SpyPresenter(result: true))

            #expect(manager.latestVersionThatReviewWasAskedFor == "1.0")
        }

        // MARK: - Prompting

        @Test("a new version prompts, reports analytics, and records the version")
        func newVersionPrompts() {
            let presenter = SpyPresenter(result: true)
            let manager = makeManager(appVersion: "1.5", presenter: presenter)

            withAnalyticsSpy { spy in
                manager.promptReviewAlert()

                #expect(spy.types == [.reviewPrompt])
            }

            #expect(presenter.attempts == 1)
            #expect(storedVersion == "1.5")
            #expect(manager.latestVersionThatReviewWasAskedFor == "1.5")
        }

        @Test("the same version never prompts twice")
        func sameVersionDoesNotPrompt() {
            let presenter = SpyPresenter(result: true)
            let manager = makeManager(appVersion: "1.5", presenter: presenter)

            withAnalyticsSpy { spy in
                manager.promptReviewAlert()
                manager.promptReviewAlert()
                manager.promptReviewAlert()

                #expect(spy.count(of: .reviewPrompt) == 1)
            }

            #expect(presenter.attempts == 1)
        }

        @Test("a version bump re-arms the prompt")
        func versionBumpRearms() {
            let presenter = SpyPresenter(result: true)
            isolated.defaults.set("1.5", forKey: ReviewManager.lastAskedVersionKey)

            let manager = makeManager(appVersion: "1.6", presenter: presenter)
            withAnalyticsSpy { _ in manager.promptReviewAlert() }

            #expect(presenter.attempts == 1)
            #expect(storedVersion == "1.6")
        }

        // MARK: - Not prompting

        @Test("an unreadable app version is a no-op that leaves storage untouched")
        func nilVersionIsNoOp() {
            let presenter = SpyPresenter(result: true)
            let manager = makeManager(appVersion: nil, presenter: presenter)

            withAnalyticsSpy { spy in
                manager.promptReviewAlert()

                #expect(spy.calls.isEmpty)
            }

            #expect(presenter.attempts == 0)
            #expect(storedVersion == nil)
        }

        @Test("a version matching the seed does not prompt on first launch")
        func seedVersionDoesNotPrompt() {
            let presenter = SpyPresenter(result: true)
            let manager = makeManager(appVersion: "1.0", presenter: presenter)

            withAnalyticsSpy { spy in
                manager.promptReviewAlert()

                #expect(spy.calls.isEmpty)
            }

            #expect(presenter.attempts == 0)
            #expect(storedVersion == nil)
        }

        // MARK: - Declined presentation

        /// StoreKit declines silently with no foreground-active scene. Analytics must not
        /// claim a prompt happened — but the version *is* still recorded, which spends the
        /// user's single chance for this version. Pinned deliberately: if that is ever
        /// considered a bug, this is the test that has to change.
        @Test("a declined presentation reports nothing yet still burns the version")
        func declinedPresentationBurnsVersion() {
            let presenter = SpyPresenter(result: false)
            let manager = makeManager(appVersion: "1.5", presenter: presenter)

            withAnalyticsSpy { spy in
                manager.promptReviewAlert()

                #expect(spy.calls.isEmpty)
            }

            #expect(presenter.attempts == 1)
            #expect(storedVersion == "1.5")
        }

        @Test("a later launch does not retry a declined version")
        func declinedVersionIsNotRetried() {
            let firstLaunch = SpyPresenter(result: false)
            withAnalyticsSpy { _ in
                makeManager(appVersion: "1.5", presenter: firstLaunch).promptReviewAlert()
            }

            let secondLaunch = SpyPresenter(result: true)
            withAnalyticsSpy { spy in
                makeManager(appVersion: "1.5", presenter: secondLaunch).promptReviewAlert()

                #expect(spy.calls.isEmpty)
            }

            #expect(secondLaunch.attempts == 0)
        }

        // MARK: - Isolation

        @Test("the injected store is used instead of standard defaults")
        func doesNotTouchStandardDefaults() {
            let key = ReviewManager.lastAskedVersionKey
            let before = UserDefaults.standard.string(forKey: key)

            let manager = makeManager(appVersion: "9.9", presenter: SpyPresenter(result: true))
            withAnalyticsSpy { _ in manager.promptReviewAlert() }

            #expect(UserDefaults.standard.string(forKey: key) == before)
            #expect(storedVersion == "9.9")
        }
    }
}
