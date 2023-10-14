//
//  MenuBlockView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import SwiftUI

struct MenuBlockView: View {
    @Environment(\.colorScheme) var colorScheme

    let category: CategoryDSItem

    @Binding var items: [DSItem]

    var body: some View {
        ZStack(alignment: .leading) {
            colorShape
            content
        }
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: category.color.opacity(0.4), radius: 5, x: 0, y: 5)
    }

    @ViewBuilder
    var colorShape: some View {
        if colorScheme == .dark {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: .init(
                            colors: [
                                category.color.opacity(0.84).darker(),
                                category.color.darker(),
                            ]
                        ),
                        startPoint: .init(x: 0.0, y: 0),
                        endPoint: .init(x: 0.9, y: 0.8)
                    )
                )
        } else {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: .init(
                            colors: [
                                category.color.opacity(0.7),
                                category.color,
                            ]
                        ),
                        startPoint: .init(x: 0.0, y: 0),
                        endPoint: .init(x: 0.9, y: 0.8)
                    )
                )
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            emoji
            nameText
            itemCount
        }
        .padding(12)
    }

    @ViewBuilder
    var emoji: some View {
        Image(systemName: category.sfSymbolName)
            .imageScale(.large)
            .foregroundColor(.white)
    }

    var nameText: some View {
        Text(category.name)
            .font(.system(.headline, design: .rounded))
            .bold()
    }

    var itemCount: some View {
        Text("^[\(findItemCount()) event](inflect: true)")
            .font(.system(.caption, design: .rounded))
    }

    func findItemCount() -> Int {
        return items.filter { $0.category == category }.count
    }
}

struct MenuBlockView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBlockView(category: .work, items: .constant([]))
            .preferredColorScheme(.dark)
    }
}
