//
//  SupportHighlightedSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 30/12/2021.
//

import SwiftUI

struct SupportHighlightedSection: View {
    @EnvironmentObject var support: SupportFetcher

    var body: some View {
        ForEach(support.highlightedSections) { section in
            Section {
                ForEach(section.items) { item in
                    NavigationLink {
                        SupportItemDetailView(item: item)
                    } label: {
                        HighlightedItemView(item: item)
                    }
                    .listRowBackground(Design.listRowBackgroundColor)
                }
            } header: {
                if !section.title.isEmpty {
                    Text(section.title)
                } else {}
            }
        }
    }
}

struct SupportHighlightedSection_Preview: PreviewProvider {
    static var previews: some View {
        SupportHighlightedSection()
    }
}
