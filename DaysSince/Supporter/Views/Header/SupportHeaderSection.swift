//
//  SupportHeaderSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 30/12/2021.
//

import SwiftUI

struct SupportHeaderSection: View {
    
    @EnvironmentObject var support: SupportFetcher
    
    var body: some View {
        Section {
            TabView {
                ForEach(support.headerItems) { item in
                    NavigationLink {
                        SupportItemDetailView(item: item)
                    } label: {
                        SupportHeaderView(item: item)
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }
            .tabViewStyle(.page)
            .frame(height: 180)
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
        }
        .listRowBackground(Color(.systemBackground))
    }
}

struct SupportHeaderSection_Previews: PreviewProvider {
    static var previews: some View {
        SupportHeaderSection()
    }
}
