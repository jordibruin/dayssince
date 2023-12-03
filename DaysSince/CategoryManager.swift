//
//  CategoryManager.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/24/23.
//

import Defaults
import Foundation
import SwiftUI

class CategoryManager: ObservableObject {
    @Default(.categories) var categories: [Category]
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    func addCategory(name: String, emoji: String, color: CategoryColor) {
        let newCategory = Category(name: name, emoji: emoji, color: color)
        categories.append(newCategory)
    }

    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }

        let categoryToDelete = categories[index]

        if !isCategoryEmpty(category: categoryToDelete) {
            print("Can't delete category. There are existing events in that category.")
            return
        }

        categories.remove(at: index)
        print("Delete category \(categoryToDelete.name)")
    }

    func deleteCategory(category: Category) {
        if !isCategoryEmpty(category: category) {
            print("Can't delete category. There are existing events in that category.")
            return
        }

        guard let indexToDelete = categories.firstIndex(of: category) else { return }

        categories.remove(at: indexToDelete)
        print("Delete category \(category.name)")
    }

    func isCategoryEmpty(category: Category) -> Bool {
        if items.contains(where: { $0.category == category }) {
            return false
        }
        return true
    }

    func isCategoryEmpty(index: Int) -> Bool {
        guard index < categories.count else { return false }

        let category = categories[index]

        if items.contains(where: { $0.category == category }) {
            return false
        }

        return true
    }
}