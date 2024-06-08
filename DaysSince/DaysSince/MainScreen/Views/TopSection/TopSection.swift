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
    @State private var draggedCategory: Category?

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
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 20))
                        .onDrag {
                            self.draggedCategory = category
                            return NSItemProvider()
                        }
                        .onDrop(of: [.text],
                                delegate: DropViewDelegate(destinationCategory: category, categoryManager: categoryManager, draggedCategory: $draggedCategory))
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
                            if categoryManager.isCategoryEmpty(category: category, items: items) {
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
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .padding(.leading, 16)
        .confirmationDialog(
            Text("Are you sure you want to delete this category?"),
            isPresented: $showDeleteCategoryAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeOut) { categoryManager.deleteCategory(category: selectedCategory!, items: items) }
            }
        }
        .alert("Unable to Delete Category", isPresented: $showUnableToDeleteCategory) {} message: {
            Text("Category contains existing events.")
        }
        .sheet(isPresented: $showEditCategory) {
            EditCategorySheet(items: $items, category: selectedCategory!)
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
                EditCategorySheet(items: $items, category: index)
            }
        }
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), isDaysDisplayModeDetailed: .constant(false))
    }
}

// Delegate class to handle drop action
struct DropViewDelegate: DropDelegate {
    @Default(.categories) var categories

    let destinationCategory: Category
    var categoryManager: CategoryManager

    @Binding var draggedCategory: Category?

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        draggedCategory = nil
        return true
    }

    // Method to update the data model when an item is dropped
    func dropEntered(info _: DropInfo) {
        withAnimation {
            categoryManager.move(destinationCategory: destinationCategory, draggedCategory: draggedCategory)
        }
    }
}
