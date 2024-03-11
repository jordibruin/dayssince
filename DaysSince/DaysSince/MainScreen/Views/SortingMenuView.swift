//
//  SortingMenuView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import Defaults
import SwiftUI

enum SortType: String, CaseIterable, Identifiable {
    case alphabeticallyAscending
    case alphabeticallyDescending
    case daysAscending
    case daysDescending
    case category
//    case created

    var id: String { rawValue }

    var name: String {
        switch self {
        case .alphabeticallyAscending:
            return "Alphabetical (A-Z)"
        case .alphabeticallyDescending:
            return "Alphabetical (Z-A)"
        case .daysAscending:
            return "Days (New-Old)"
        case .daysDescending:
            return "Days (Old-New)"
        case .category:
            return "Category"
//        case .created:
//            return "Created"
        }
    }

    func sort(itemOne: DSItem, itemTwo: DSItem) -> Bool {
        switch self {
        case .alphabeticallyAscending:
            return itemOne.name < itemTwo.name
        case .alphabeticallyDescending:
            return itemOne.name > itemTwo.name
        case .daysAscending:
            return itemOne.daysAgo < itemTwo.daysAgo
        case .daysDescending:
            return itemOne.daysAgo > itemTwo.daysAgo
        case .category:
            return itemOne.category.name > itemTwo.category.name
//        case .created:
//            return true
        }
    }
}

struct SortingMenuView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var items: [DSItem]

    @State var sortType = "none"
    @State var descending = true
    @State var image = "arrow.down"

    @AppStorage("selectedSortType") var selectedSortType: SortType = .daysAscending

    @Default(.mainColor) var mainColor

    var body: some View {
        Menu {
            ForEach(SortType.allCases) { type in
                Button {
                    selectedSortType = type
                } label: {
                    HStack {
                        Text(type.name)
                        Spacer()
                        if type == selectedSortType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .imageScale(.large)
                .font(.title2)
                .foregroundColor(colorScheme == .dark ? .primary : mainColor.opacity(0.8))
        }
        .foregroundColor(.primary)
        .accessibilityLabel("Sorting Menu")
    }
}

struct SortingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SortingMenuView(items: .constant([]))
    }
}
