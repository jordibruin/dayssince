//
//  CategoryManager.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/24/23.
//

import Defaults
import Foundation
import SwiftUI
import Combine

/// Manages anything related to the categories (adding, editing, deleting, etc.)
class CategoryManager: ObservableObject {
    
    // Computed property for categories
    private var categories: [Category] {
        get { Defaults[.categories] }
        set { Defaults[.categories] = newValue }
    }

    /// Create a new category
    /// - Parameters:
    ///   - name: String name of new category
    ///   - emoji: String, sfSymbol of new category
    ///   - color: CategoryColor, color of the new category
    func addCategory(name: String, emoji: String, color: CategoryColor) {
        let newCategory = Category(name: name, emoji: emoji, color: color)
        categories.append(newCategory)
    }

    /// Delete a category
    /// - Parameter index: the index to be deleted of the categories array where the categories are being store
    func deleteCategory(at index: Int, items: [DSItem]) {
        guard index < categories.count else { return }

        let categoryToDelete = categories[index]

        if !isCategoryEmpty(category: categoryToDelete, items: items) {
            print("Can't delete category. There are existing events in that category.")
            return
        }

        categories.remove(at: index)
        print("Delete category \(categoryToDelete.name)")
    }

    /// Delete a category
    /// - Parameter category: Category, the category instance to be deleted
    func deleteCategory(category: Category, items: [DSItem]) {
        withAnimation {
            if !isCategoryEmpty(category: category, items: items) {
                print("Can't delete category. There are existing events in that category.")
                return
            }

            guard let indexToDelete = categories.firstIndex(of: category) else { return }

            categories.remove(at: indexToDelete)
            print("Delete category \(category.name)")
        }
        objectWillChange.send() // makes the animation work
    }

    /// Edit an existing category
    /// - Parameters:
    ///   - category: Category, the instance to be updated
    ///   - name: String, (new) name of the category
    ///   - emoji: String, (new) sfSymbol
    ///   - color: CategoryColor, (new) color
    func updateCategory(category: Category, name: String, emoji: String, color: CategoryColor, items: inout [DSItem]) {
        withAnimation {
            guard let indexToUpdate = categories.firstIndex(of: category) else { return }
            categories[indexToUpdate].name = name
            categories[indexToUpdate].emoji = emoji
            categories[indexToUpdate].color = color

            // Structs (Category) are value based, need to update the item's category too
            for index in items.indices {
                if items[index].category == category {
                    items[index].category = categories[indexToUpdate]
                }
            }
        }
        objectWillChange.send()
    }

    /// Indicates whether any Days Since events are assigned to this category
    /// - Parameter category: Category
    /// - Returns: Bool, true if no events are assigned to this category, false otherwise
    func isCategoryEmpty(category: Category, items: [DSItem]) -> Bool {
        if items.contains(where: { $0.category == category }) {
            return false
        }
        return true
    }

    /// Indicates whether any Days Since events are assigned to this category
    /// - Parameter index: Int, index of the category in the categories array in User Defaults
    /// - Returns: Bool, true if no events are assigned to this category, false otherwise
    func isCategoryEmpty(index: Int, items: [DSItem]) -> Bool {
        guard index < categories.count else { return false }

        let category = categories[index]

        if items.contains(where: { $0.category == category }) {
            return false
        }

        return true
    }

    /// Reorder the categories array in User Defaults, Used for the Drag and Drop functionaility
    /// - Parameters:
    ///   - destinationCategory: Category, the destination where we want to place it
    ///   - draggedCategory: Category?, the category we want to move
    func move(destinationCategory: Category, draggedCategory: Category?) {
        withAnimation {
            if let draggedCategory {
                let fromIndex = categories.firstIndex(of: draggedCategory)
                if let fromIndex {
                    let toIndex = categories.firstIndex(of: destinationCategory)
                    if let toIndex, fromIndex != toIndex {
                        withAnimation {
                            categories.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? (toIndex + 1) : toIndex)
                        }
                    }
                }
            }
        }
        objectWillChange.send()
    }
}
