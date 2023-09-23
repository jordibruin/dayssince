//
//  FAQItemView.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import SwiftUI

struct FAQItemView: View {
    let item: FAQItem

    var body: some View {
        DisclosureGroup {
            Text(item.text.toMarkdown())
                .foregroundColor(Design.listTextColor)
                .font(.system(.body, design: .rounded))
                .offset(x: -20)
                .padding(.vertical, 12)
                .fixedSize(horizontal: false, vertical: true)

        } label: {
            Text(item.title)
                .font(.system(.body, design: .rounded))
                .bold()
                .foregroundColor(Design.listTitleColor)
                .padding(.vertical, 12)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FAQItemView_Previews: PreviewProvider {
    static var previews: some View {
        FAQItemView(item: FAQItem.example)
    }
}
