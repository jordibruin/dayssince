//
//  SupportScreen.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation
import SwiftUI

struct SupportScreen: View {
    
    @StateObject var support = SupportFetcher()
    
    @Environment(\.presentationMode) var presentationMode
    
    // TODO: Determine best approach for hiding release note
    @AppStorage("latestVersionIdOpened") var latestVersionIdOpened: Int?
    
    // MARK: Check the Design file before uncommenting this.
    // Uncommenting this allows you to customize the background color of the Support Screen
    // But it can have side effects
//    init() {
//        UITableViewCell.appearance().backgroundColor = UIColor(Design.listBackgroundColor)
//        UITableView.appearance().backgroundColor = UIColor(Design.listBackgroundColor)
//    }
    
    @State var showChangelog: Bool = false
    
    var body: some View {
        // Comment the NavigationView if you are NOT presenting Supporter as a sheet but through a NavigationLink to remove the extra navigation bar.
//        NavigationView {
            Group {
                if support.retrievedSupport {
                    supportSections
                } else {
                    ProgressView()
                }
            }      
            // Comment this if you are NOT presenting Supporter as a sheet but through a NavigationLink to remove the close button in the top right.
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .padding(.top, 4)
//                }
//                    .font(.title)
//                    .foregroundColor(.ppBlue)
//                }
//            })
//        }
        .sheet(isPresented: $showChangelog, content: {
            ChangelogView(items: support.changelogItems)
        })
    }
    
    var supportSections: some View {
        List {
            if !latestVersionAlreadySeen {
                
                if let newestUpdate = support.changelogItems.max() {
                    NewUpdateBanner(item: newestUpdate)
                        .onTapGesture { showChangelog = true }
                }
            }
            
            if !support.headerItems.isEmpty {
                SupportHeaderSection()
            }
            
            if !support.highlightedSections.isEmpty {
                SupportHighlightedSection()
            }

            if !support.faqSections.isEmpty {
                SupportFAQSection()
            }
            
            if !support.contactSections.isEmpty || !support.contactItems.isEmpty {
                SupportContactSection()
            }
            
            // Uncomment this to show a direct link to the changelog page
            //                if !support.changelogItems.isEmpty {
            //                    Button {
            //                        showChangelog = true
            //                    } label: {
            //                        Label("Changelog", systemImage: "list.star")
            //                            .padding(.leading, -8)
            //                            .font(.title3)
            //                    }
            //                }
        }
        .listStyle(.insetGrouped)
        .environmentObject(support)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Checks to see if user already viewed the changelog for the latest app version
    /// - Returns: True if the user already visited the changelog for the latest version
    var latestVersionAlreadySeen: Bool {
        guard let newestUpdate = support.changelogItems.map ({ item in
            item.id
        }).max() else { return true }
        
        return latestVersionIdOpened == newestUpdate
    }
}

struct SupportScreen_Previews: PreviewProvider {
    static var previews: some View {
        SupportScreen()
    }
}
