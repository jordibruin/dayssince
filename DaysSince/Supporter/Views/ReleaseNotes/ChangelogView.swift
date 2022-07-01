//
//  ChangelogView.swift
//  SnoozeSupport
//
//  Created by Jordi Bruin on 02/01/2022.
//

import SwiftUI

struct ChangelogView: View {
    
    @Environment(\.presentationMode) var presentationMode
    let items: [ChangelogItem]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items.reversed()) { item in
                    ChangelogUpdateCell(item: item)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                guard let newestUpdate = items.map ({ item in
                    item.id
                }).max() else { return }
                
                // No longer show it on the main support page after a user tapped the new update icon
                UserDefaults.standard.set(newestUpdate, forKey: "latestVersionIdOpened")
            }
        }
    }
}

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView(items: [])
    }
}
