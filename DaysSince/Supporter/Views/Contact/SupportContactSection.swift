//
//  SupportContactSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 30/12/2021.
//

import SwiftUI

struct SupportContactSection: View {
    
    @EnvironmentObject var support: SupportFetcher
    
    var body: some View {
        if !support.contactSections.isEmpty {
            suppportSections
        } else {
            singleSection
        }
    }
    
    var suppportSections: some View {
        ForEach(support.contactSections) { section in
            Section {
                
                ForEach(section.items) { item in
                    ContactItemView(item: item)
//                    .listRowBackground(Design.listRowBackgroundColor)
                    
                }
            } header: {
                if !section.title.isEmpty {
                    Text(section.title)
                } else {}
            }
        }
    }
    
    var singleSection: some View {
        Section {
            ForEach(support.contactItems) { item in
                ContactItemView(item: item)
                    .listRowBackground(Design.listRowBackgroundColor)
            }
        }
    }
}

struct SupportContactSection_Previews: PreviewProvider {
    static var previews: some View {
        SupportContactSection()
    }
}
