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
    
    let itemID: UUID
    @Binding var items: [DSItem]
    
    var colored: Bool
    
    private var currentItem: DSItem? {
        items.first { $0.id == itemID }
    }

    var body: some View {
        if let item = currentItem {
            ZStack(alignment: .topTrailing) {
                itemBody(item: item)
            }
        } else {
            EmptyView()
        }
    }

    func itemBody(item: DSItem) -> some View {
        ZStack(alignment: .leading) {
            backgroundColor(item: item)
            itemContent(item: item)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark ? item.category.color.color == .black ? Color(.secondarySystemBackground) :  item.category.color.color.darker() : item.category.color.color,
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

    func nameText(item: DSItem) -> some View {
        Text(item.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color.color)
    }

    @ViewBuilder
    func daysAgoText(item: DSItem) -> some View {
        let resolvedForegroundColor = colored || colorScheme == .dark ? Color.white : item.category.color.color
        
        if isDaysDisplayModeDetailed {
            let currentDate = Date()
            let calendar = Calendar.current

            let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: item.dateLastDone), to: calendar.startOfDay(for: currentDate))

            let years = dateComponents.year ?? 0
            let months = dateComponents.month ?? 0
            let days = dateComponents.day ?? 0

            HStack {
                if years > 0 {
                    VStack {
                        Text("\(years)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .foregroundColor(resolvedForegroundColor)

                        Text(years == 1 ? "year" : "years")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(resolvedForegroundColor)
                    }
                }

                if months > 0 || years > 0 {
                    VStack {
                        Text("\(months)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .foregroundColor(resolvedForegroundColor)

                        Text(months == 1 ? "month" : "months")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(resolvedForegroundColor)
                    }
                }

                VStack {
                    Text("\(days)")
                        .font(.system(months > 0 || years > 0 ? .title3 : .title2, design: .rounded))
                        .bold()
                        .foregroundColor(resolvedForegroundColor)

                    Text(days == 1 ? "day" : "days")
                        .font(.system(months > 0 || years > 0 ? .caption : .body, design: .rounded))
                        .foregroundColor(resolvedForegroundColor)
                }
            }
            .frame(minWidth: 0)

        } else {
            VStack {
                Text("\(item.daysAgo)")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(resolvedForegroundColor)

                Text(item.daysAgo == 1 ? "day" : "days")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(resolvedForegroundColor)
            }
            .frame(minWidth: 0)
        }
    }
    
    @ViewBuilder
    func backgroundColor(item: DSItem) -> some View {
        if colorScheme == .dark {
            if item.category.color.color == .black { Color(.tertiarySystemBackground) }
            else {item.category.color.color.lighter(by: 0.04)}
        } else if colored {
            item.category.color.color
        } else {
            Color.white
        }
    }

    func itemContent(item: DSItem) -> some View {
        HStack {
            nameText(item: item)
            Spacer()
            daysAgoText(item: item)
                .onTapGesture {
                    if isDaysDisplayModeDetailed {Analytics.send(.detailedModeOn)}
                    withAnimation {
                        isDaysDisplayModeDetailed.toggle()
                    }
                }
        }
        .padding()
    }
}

struct DSItemView_Preview: PreviewProvider {
    static let mockItemID = DSItem.placeholderItem().id
    @State static var mockItems = [DSItem.placeholderItem()]
    @State static var mockTappedItem = DSItem.placeholderItem()

    static var previews: some View {
        DSItemView(editItemSheet: .constant(false),
                   tappedItem: $mockTappedItem,
                   isDaysDisplayModeDetailed: .constant(false),
                   itemID: mockItemID,
                   items: $mockItems,
                   colored: true)
            .padding()
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .light)
        
        DSItemView(editItemSheet: .constant(false),
                   tappedItem: $mockTappedItem,
                   isDaysDisplayModeDetailed: .constant(false),
                   itemID: mockItemID,
                   items: $mockItems,
                   colored: true)
            .padding()
            .previewLayout(.sizeThatFits)
            .background(Color.black)
            .environment(\.colorScheme, .dark)
    }
}
