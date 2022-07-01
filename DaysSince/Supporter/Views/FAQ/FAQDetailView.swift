//
//  FAQDetailView.swift
//  SnoozeSupport
//
//  Created by Jordi Bruin on 03/01/2022.
//

import SwiftUI

struct FAQDetailView: View {
    
    let section: FAQSection
    
    var body: some View {
        List {
            ForEach(section.items) { item in
                FAQItemView(item: item)
            }
        }
        .navigationTitle(section.title)
    }
}

struct FAQDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FAQDetailView(
            section: FAQSection(
                id: 1,
                title: "",
                items: [
                    FAQItem(id: 1, title: "FAQ item Title", text: "FAQ Item text")
                ]
            )
        )
    }
}
