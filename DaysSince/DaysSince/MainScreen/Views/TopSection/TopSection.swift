//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import Defaults
import SwiftUI

/**
 The top section of the main screen contains the grid with the categories for the events.
 By clicking on any of the categories it will lead you to a filtered view with events only from that category.
 */
struct TopSection: View {
    @EnvironmentObject var categoryManager: CategoryManager

    @Default(.categories) var categories

    @Binding var items: [DSItem]
    @Binding var isDaysDisplayModeDetailed: Bool

    @State var showDeleteCategoryAlert: Bool = false
    @State var showUnableToDeleteCategory: Bool = false
    @State var selectedCategory: Category? = nil
    @State var showEditCategory: Bool = false

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(categories, id: \.hashableIdentifier) { category in

                    NavigationLink(
                        destination: CategoryFilteredView(
                            category: category,
                            showAddItemSheet: false,
                            editItemSheet: false,
                            items: $items,
                            isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                        )
                    ) {
                        MenuBlockView(
                            category: category,
                            items: $items
                        )
                        .aspectRatio(1.0, contentMode: .fit) // Maintain square aspect ratio
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
                    .contextMenu {
                        Button {
                            selectedCategory = category
                            showEditCategory = true
                        } label: {
                            Label("Edit Category", systemImage: "rectangle.and.pencil.and.ellipsis")
                        }

                        Button {
                            if categoryManager.isCategoryEmpty(category: category) {
                                selectedCategory = category
                                showDeleteCategoryAlert = true
                            } else {
                                showUnableToDeleteCategory = true
                            }
                        } label: {
                            Label("Delete Category", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
        }
        .padding(.leading, 16)
        .confirmationDialog(
            Text("Are you sure you want to delete this category?"),
            isPresented: $showDeleteCategoryAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeOut) { categoryManager.deleteCategory(category: selectedCategory!) }
            }
        }
        .alert("Unable to Delete Category", isPresented: $showUnableToDeleteCategory) {} message: {
            Text("Category contains existing events.")
        }
        .sheet(isPresented: $showEditCategory) {
            EditCategorySheet(category: selectedCategory!)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.medium])
                .presentationCornerRadius(44)
                .onDisappear {
                    showEditCategory = false
                    selectedCategory = nil
                }
        }

        .sheet(isPresented: Binding<Bool>(
            get: { showEditCategory && selectedCategory != nil },
            set: { newValue in
                showEditCategory = newValue
            }
        )) {
            if let index = selectedCategory {
                EditCategorySheet(category: index)
            }
        }
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), isDaysDisplayModeDetailed: .constant(false))
    }
}
