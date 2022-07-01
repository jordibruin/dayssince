//
//  ChangelogUpdateCell.swift
//  SnoozeSupport
//
//  Created by Jordi Bruin on 02/01/2022.
//

import SwiftUI

struct ChangelogUpdateCell: View {
    
    let item: ChangelogItem
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(item.notes) { note in
                    Text("• \(note.releaseNote)")
                }
            }
            .padding(.vertical, 12)
        } header: {
            HStack {
                Text(item.version)
                    .bold()
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(nil)
                    .padding(.leading, -8)
            }
        }
    }
}

struct ChangelogUpdateCell_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogUpdateCell(item: ChangelogItem(id: 1, version: "test", notes: [
        ReleaseNote(id: 1, releaseNote: "Note"),
        ReleaseNote(id: 2, releaseNote: "Notesds"),
        ReleaseNote(id: 3, releaseNote: "Note"),
        ]))
    }
}
