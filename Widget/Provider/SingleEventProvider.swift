//
//  SingleEventProvider.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import Foundation
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    func placeholder(in _: Context) -> WidgetContent {
        let content = WidgetContent(date: Date(), name: "Adopted Leo 🐱", id: UUID(), color: Color.lifeColor, daysNumber: 237)

        return content
    }

    public func getSnapshot(
        for _: SelectEventIntent,
        in _: Context,
        completion: @escaping (WidgetContent) -> Void
    ) {
        let content = WidgetContent(date: Date(), name: "Adopted Charlie 🐶", id: UUID(), color: .green, daysNumber: 45)
        completion(content)
    }

    public func getTimeline(
        for configuration: SelectEventIntent,
        in _: Context,
        completion: @escaping (Timeline<WidgetContent>) -> Void
    ) {
        if let matchingEvent = DSItem.first(matching: configuration.event?.identifier, in: items) {
            let content = WidgetContent(item: matchingEvent)
            completion(Timeline(entries: [content], policy: .atEnd))
        } else {
            let content = WidgetContent(date: Date(), name: "No event", id: UUID(), color: .green, daysNumber: 4)
            completion(Timeline(entries: [content], policy: .atEnd))
        }
    }
}
