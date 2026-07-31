@testable import DaysSince
import Foundation
import Testing

extension GlobalStateSuite {

    @Suite("Analytics facade")
    struct AnalyticsFacadeTests {

        @Test("default sink is TelemetryDeck")
        func defaultSink() {
            #expect(Analytics.sink is TelemetryDeckSink)
        }

        @Test("send forwards the event with no parameters")
        func forwardsWithoutParameters() {
            withAnalyticsSpy { spy in
                Analytics.send(.chooseTheme)

                #expect(spy.calls == [.init(type: .chooseTheme, parameters: nil)])
            }
        }

        @Test("send forwards additional parameters unchanged")
        func forwardsParameters() {
            withAnalyticsSpy { spy in
                Analytics.send(.addNewEvent, with: ["remindersEnabled": "true"])

                #expect(spy.parameters(of: .addNewEvent) == ["remindersEnabled": "true"])
            }
        }

        @Test("repeated events are recorded in order")
        func recordsOrder() {
            withAnalyticsSpy { spy in
                Analytics.send(.chooseTheme)
                Analytics.send(.chooseIcon)
                Analytics.send(.chooseTheme)

                #expect(spy.types == [.chooseTheme, .chooseIcon, .chooseTheme])
                #expect(spy.count(of: .chooseTheme) == 2)
            }
        }

        @Test("the previous sink is restored afterwards")
        func restoresPreviousSink() {
            withAnalyticsSpy { _ in
                #expect(Analytics.sink is SpyAnalytics)
            }

            #expect(Analytics.sink is TelemetryDeckSink)
        }
    }
}
