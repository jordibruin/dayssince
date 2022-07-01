//
//  ReleaseNoteDetail.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import SwiftUI

struct ReleaseNoteDetail: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
        
    let appStoreURL: String = "https://apps.apple.com/nl/app/bakery-simple-icon-creator/id1575220747"
    let releaseNote: SupportReleaseNote
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(releaseNote.title)
                            .font(.system(.title, design: .rounded))
                            .bold()
                        Text("Version \(releaseNote.version)".uppercased())
                            .font(.system(.caption, design: .rounded))
                            .opacity(0.7)
                    }
                    .padding(.trailing, 40)
                    
                    Text(releaseNote.description)
                        .font(.system(.body, design: .rounded))
                    
                    updateButton
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
//                        dismiss()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                    }

                }
            }
        }
    }
    
    
    
    var updateButton: some View {
        Group {
            if #available(iOS 15.0, *) {
                Button {
                    openURL(URL(string: appStoreURL)!)
                } label: {
                    Text("Update now")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    openURL(URL(string: appStoreURL)!)
                } label: {
                    Text("Update now")
                }
                .buttonStyle(.plain)
            }
        }
    }
    
}

struct ReleaseNoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseNoteDetail(releaseNote: SupportReleaseNote(id: 1, title: "Big Release", version: "1.11", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))
    }
}
