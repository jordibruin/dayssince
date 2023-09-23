//
//  NewUpdateBanner.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import SwiftUI

struct NewUpdateBanner: View {
    let item: ChangelogItem

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button {} label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    // .symbolRenderingMode(.hierarchical) iOS 15
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()

                        Spacer()
                    }
                )
            textContent
        }
        // Make the content fill the entire space of the cell
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        // Prevent taps from lighting up the cell
        .buttonStyle(FlatLinkStyle())
    }

    var titleAndVersion: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.version)
                .font(.system(.title2, design: .rounded))
                .bold()
        }
        .padding(.trailing, 40)
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleAndVersion

            VStack(alignment: .leading, spacing: 8) {
                ForEach(item.notes.prefix(2)) { note in
                    Text("• \(note.releaseNote)")
                }

                if item.notes.count > 2 {
                    Text("...")
                }
            }
        }
        .foregroundColor(.primary)
        .multilineTextAlignment(.leading)
        .padding()
    }
}

struct NewUpdateBanner_Previews: PreviewProvider {
    static var previews: some View {
        NewUpdateBanner(item: ChangelogItem(id: 1, version: "1.2", date: "January", notes: [
            ReleaseNote(id: 1, releaseNote: "Updated something"),
            ReleaseNote(id: 2, releaseNote: "Fixed something else"),
            ReleaseNote(id: 3, releaseNote: "Bugfixes"),
        ]))
    }
}
