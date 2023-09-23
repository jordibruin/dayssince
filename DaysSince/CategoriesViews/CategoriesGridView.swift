//
//  CategoriesGridView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct CategoriesGridView: View {
    @Binding var selectedCategory: CategoryDSItem?

    @State var addItem: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                CategoryRectangleView(category: .work, selectedCategory: selectedCategory)
                    .onTapGesture {
                        selectedCategory = .work
                    }
                CategoryRectangleView(category: .life, selectedCategory: selectedCategory)
                    .onTapGesture {
                        selectedCategory = .life
                    }
            }
            VStack {
                CategoryRectangleView(category: .health, selectedCategory: selectedCategory)
                    .onTapGesture {
                        selectedCategory = .health
                    }
                CategoryRectangleView(category: .hobbies, selectedCategory: selectedCategory)
                    .onTapGesture {
                        selectedCategory = .hobbies
                    }
            }
        }
    }
}

struct CategoriesGridView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesGridView(selectedCategory: .constant(CategoryDSItem.hobbies), addItem: true)
    }
}
