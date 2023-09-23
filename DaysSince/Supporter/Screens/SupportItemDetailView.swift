//
//  SupportItemDetailView.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import SwiftUI

struct SupportItemDetailView: View {
    let item: SupportPageable
    @State var activePage: Int = 0

    var body: some View {
        tabView()
            .navigationBarTitleDisplayMode(.inline)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    @ViewBuilder
    func tabView() -> some View {
        if item.supportPages.isEmpty {
            Text("No pages for this support item")
        } else {
            TabView(selection: $activePage) {
                ForEach(item.supportPages) { page in
                    SupportItemPageView(page: page)
                }
            }
            .background(
                Design.backgroundColor
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
    }
}

struct SupportItemView_Previews: PreviewProvider {
    static var previews: some View {
        SupportItemDetailView(item: HighlightedItem.example)
    }
}
