//
//  DSItemView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/7/22.
//

import Foundation
import SwiftUI

struct DSItemView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem
    @Binding var isDaysDisplayModeDetailed: Bool

    var item: DSItem
    var colored: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            itemBody
        }
    }

    var itemBody: some View {
        ZStack(alignment: .leading) {
            backgroundColor
            itemContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark ? item.category.color.color.darker() : item.category.color.color,
                    lineWidth: 3
                )
        )
        .padding(.horizontal, 1.6)
        .padding(.vertical, 1.61)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
        .onTapGesture {
            editItemSheet = true
            tappedItem = item
        }
    }

    var nameText: some View {
        Text(item.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
    }

    @ViewBuilder
    var daysAgoText: some View {
        if isDaysDisplayModeDetailed {
            let currentDate = Date()
            let calendar = Calendar.current

            let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: item.dateLastDone), to: calendar.startOfDay(for: currentDate))

            let years = dateComponents.year ?? 0
            let months = dateComponents.month ?? 0
            let days = dateComponents.day ?? 0

            // Show years, months and days
            HStack {
                if years > 0 {
                    VStack {
                        Text("\(years)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)

                        Text(years == 1 ? "year" : "years")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
                    }
                }

                if months > 0 || years > 0 {
                    VStack {
                        Text("\(months)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)

                        Text(months == 1 ? "month" : "months")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
                    }
                }

                VStack {
                    Text("\(days)")
                        .font(.system(months > 0 || years > 0 ? .title3 : .title2, design: .rounded))
                        .bold()
                        .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)

                    Text(days == 1 ? "day" : "days")
                        .font(.system(months > 0 || years > 0 ? .caption : .body, design: .rounded))
                        .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
                }
            }
            .frame(minWidth: 0)

            // If user just wants to see the days.
        } else {
            VStack {
                Text("\(item.daysAgo)")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)

                Text(item.daysAgo == 1 ? "day" : "days")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
            }
            .frame(minWidth: 0)
        }
    }

    @ViewBuilder
    var backgroundColor: some View {
        if colorScheme == .dark {
            item.category.color.color.lighter(by: 0.04)
        } else if colored {
            item.category.color.color
        } else {
            Color.white
        }
    }

    var itemContent: some View {
        HStack {
            nameText
            Spacer()
            daysAgoText
                .onTapGesture {
                    withAnimation {
                        isDaysDisplayModeDetailed.toggle()
                    }
                }
        }
        .padding()
    }
}

struct DSItemView_Preview: PreviewProvider {
    static var previews: some View {
        DSItemView(editItemSheet: .constant(false),
                   tappedItem: .constant(DSItem.placeholderItem()),
                   isDaysDisplayModeDetailed: .constant(false),
                   item: DSItem.placeholderItem(),
                   colored: true)
            .frame(height: 10)
    }
}
