//
//  WidgetLockedView.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 28/03/2026.
//

import SwiftUI
import WidgetKit

struct WidgetLockedView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(family == .systemSmall ? .title3 : .title2)
                .foregroundColor(.secondary)

            Text("Upgrade to Pro\nfor full access")
                .font(.system(family == .systemSmall ? .caption : .subheadline, design: .rounded))
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.clear }
    }
}
