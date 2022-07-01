//
//  SupportFAQSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 30/12/2021.
//

import SwiftUI

struct SupportFAQSection: View {
    
    @EnvironmentObject var support: SupportFetcher
    
    var body: some View {
        ForEach(support.faqSections) { section in
            Section {
                ForEach(section.hasDetailPage ? Array(section.items.prefix(3)) : section.items) { item in
                    FAQItemView(item: item)
                        .listRowBackground(Design.listRowBackgroundColor)
                }
                
                if section.hasDetailPage {
                    NavigationLink {
                        FAQDetailView(section: section)
                    } label: {
                        Text(section.viewAllText)
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(Design.listTitleColor)
                            .padding(.vertical, 12)
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

struct SupportFAQSection_Previews: PreviewProvider {
    static var previews: some View {
        SupportFAQSection()
    }
}
