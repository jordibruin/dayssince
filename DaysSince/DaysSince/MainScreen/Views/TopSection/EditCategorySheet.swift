//
//  EditCategorySheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/11/24.
//

import SwiftUI

struct EditCategorySheet: View {
    @Default(.categories) var categories

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryManager: CategoryManager
    
    @Binding var items: [DSItem]

    var category: Category
    @State var selectedName: String = ""
    @State var selectedColor: CategoryColor = .work
    @State var selectedEmoji: String = "lightbulb"
    @State var showMoreCategorySfSymbols: Bool = false
    @State var emojis: [String] = ["lightbulb", "leaf", "gamecontroller", "heart.text.square", "graduationcap", "bell", "gift.fill", "heart", "laptopcomputer", "airplane"]

    private func updateStateVariables() {
        selectedName = category.name
        selectedColor = category.color
        selectedEmoji = category.emoji
    }

    var body: some View {
        ScrollView {
            header
            name
            emoji
            color
        }
        .padding(.horizontal, 16)
        .onAppear {
            updateStateVariables()
        }
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
                    Text("Edit Category")
                        .font(.system(.body, design: .rounded))
                        .bold()

                    // Custom divider elebent
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 72, height: 2)
                        .opacity(0.5)
                        .foregroundColor(Color.primary.opacity(0.4))
                }

                Spacer()
            }
            HStack {
                Spacer()

                Button {
                    withAnimation {
                        categoryManager.updateCategory(category: category, name: selectedName, emoji: selectedEmoji, color: selectedColor, items: &items)
                        dismiss()
                    }
                } label: {
                    Text("Save")
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

import Defaults
import SwiftUI

// #Preview {
//    EditCategorySheet()
// }
