//
//  AddCategorySheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/25/23.
//

import Defaults
import SwiftUI

struct AddCategorySheet: View {
    @Default(.categories) var categories

    @State var selectedName: String = ""
    @State var selectedColor: CategoryColor = .work
    @State var selectedEmoji: String = "lightbulb"
    @State var showMoreCategorySfSymbols: Bool = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoriesManager: CategoryManager

    @State var emojis: [String] = ["lightbulb", "leaf", "gamecontroller", "heart.text.square", "graduationcap", "bell", "gift.fill", "heart", "laptopcomputer", "airplane"]

    var body: some View {
        ScrollView {
            header
            name
            emoji
            color
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showMoreCategorySfSymbols, onDismiss: updateCategoryEmojis) {
            MoreSfSymbolsView(accentColor: accentColor, selectedEmoji: $selectedEmoji)
        }
    }

    func updateCategoryEmojis() {
        if !emojis.contains(selectedEmoji) {
            withAnimation { emojis.insert(selectedEmoji, at: 0) }
        }
    }

    var header: some View {
        ZStack {
            HStack {
                Spacer()

                VStack(spacing: 4) {
                    Text("New Category")
                        .font(.system(.body, design: .rounded))
                        .bold()

                    // Custom divider elebent
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 72, height: 2)
                        .opacity(0.5)
                }
                .foregroundColor(Color.primary.opacity(0.4))
                Spacer()
            }
            HStack {
                Spacer()

                Button {
                    withAnimation {
                        categoriesManager.addCategory(name: selectedName, emoji: selectedEmoji, color: selectedColor)
                        dismiss()
                    }
                } label: {
                    Text("Add")
                        .bold()
                        .foregroundColor(isCategoryCreationValid ? accentColor : Color.gray)
                        .padding(8)
                        .padding(.horizontal, 8)
                        .background(isCategoryCreationValid ? accentColor.opacity(0.16).cornerRadius(20) : Color.gray.opacity(0.16).cornerRadius(20))
                }
                .disabled(selectedName.isEmpty)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }

    var name: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NAME")
                .font(.caption)
                .opacity(0.6)
                .padding(.leading, 20)

            HStack {
                TextField("Enter category name", text: $selectedName)

                Spacer()
            }
            .padding(12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.bottom, 8)
    }

    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 50, maximum: 50), spacing: 24),
    ]

    var emoji: some View {
        VStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("EMOJI")
                    .font(.caption)
                    .opacity(0.6)
                    .padding(.leading, 20)

                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: 20
                ) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Image(systemName: emoji)
                                .font(.title)
                                .foregroundColor(selectedEmoji == emoji ? accentColor : .primary)
                                .padding(10)
                                .background(accentColor.opacity(0.16).opacity(selectedEmoji == emoji ? 1 : 0))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(16)
            }

            HStack {
                Spacer()

                Button {
                    showMoreCategorySfSymbols = true
                } label: {
                    Text("More")
                        .foregroundColor(.primary)
                        .bold()
                }
                .padding()
                .background(Color.primary.opacity(0.1))
                .cornerRadius(16)
            }
        }
        .padding(.bottom, 8)
    }

    var color: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("COLOR")
                .font(.caption)
                .opacity(0.6)
                .padding(.leading, 20)

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20
            ) {
                ForEach(CategoryColor.allCases, id: \.self.id) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        Image(systemName: selectedColor == color ? "app.fill" : "app")
                            .font(.title)
                            .bold()
                            .foregroundColor(color.color)
                    }
                }
            }
            .padding(12)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(16)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Actions

    var isCategoryCreationValid: Bool {
        return !selectedName.isEmpty
    }

    var buttonColor: Color {
        return isCategoryCreationValid ? .accentColor : .gray
    }

    var accentColor: Color { selectedColor.color }
}

struct AddCategorySheet_Previews: PreviewProvider {
    static var previews: some View {
        AddCategorySheet()
    }
}
