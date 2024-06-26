//
//  CategoryFormSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/25/23.
//

import Defaults
import SwiftUI

struct CategoryFormSection: View {
    @Default(.categories) var categories

    @Binding var selectedCategory: Category?
    @Binding var showCategorySheet: Bool

    var accentColor: Color { selectedCategory?.color.color ?? Color.black }

    var body: some View {
        Section {
            categoriesList
            addCategoryButton
        } header: {
            Text("Category")
        }
    }

    var categoriesList: some View {
        ForEach(categories, id: \.id) { category in
            Button {
                withAnimation { selectedCategory = category }
            } label: {
                HStack {
                    Image(systemName: category.emoji)
                        .foregroundColor(selectedCategory == category ? accentColor : .primary)
                        .frame(width: 40)

                    Text(category.name)
                    Spacer()

                    if selectedCategory == category {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(accentColor)
                    }
                }
            }
            .foregroundColor(.primary)
        }
    }

    var addCategoryButton: some View {
        HStack {
            Spacer()
            Button {
                showCategorySheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .foregroundColor(.primary)
                    Text("Add Category")
                        .foregroundColor(.primary)
                        .bold()
                }
            }
            .padding()
            .background(Color.primary.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct CategoryFormSection_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFormSection(selectedCategory: .constant(nil), showCategorySheet: .constant(false))
    }
}
