//
//  CategoryFormSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/25/23.
//

import Defaults
import SwiftUI

struct CategoryFormSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Default(.categories) var categories

    @Binding var selectedCategory: Category?
    @Binding var showCategorySheet: Bool
    
    var showHeader: Bool = true
    var accentColor: Color { selectedCategory == nil ? Color.primary :  selectedCategory?.color.color == .black && colorScheme == .dark ? Color.white : selectedCategory!.color.color }
    

    var body: some View {
        Section {
            categoriesList
            addCategoryButton
        } header: {
            if showHeader {
                Text("Category")
            }
        }
    }

    var categoriesList: some View {
        VStack(spacing: 8) { // Adjust vertical spacing here
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
                    .padding(12) // Inner padding
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                }
                .foregroundColor(.primary)
            }
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
