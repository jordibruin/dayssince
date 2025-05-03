//
//  CategoryFilteredView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/8/22.
//

import SwiftUI
import Defaults

struct CategoryFilteredView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var reviewManager: ReviewManager
    
    @Default(.categories) var categories
    
    let categoryID: UUID

    @State var showAddItemSheet: Bool
    @State var editItemSheet: Bool
    @State var tappedItem: DSItem = .placeholderItem()
    @State var showConfirmDelete = false
    @State var showUnableToDelete = false
    @State var showEditCategory: Bool = false

    @Binding var items: [DSItem]
    @Binding var isDaysDisplayModeDetailed: Bool

    @EnvironmentObject var categoryManager: CategoryManager

    
    private var currentCategory: Category? {
        categories.first { $0.id == categoryID }
    }
    
    var accentColor: Color { currentCategory?.color.color ?? Color.workColor}

    var body: some View {
        if let category = currentCategory {
            ZStack {
                background(for: category)
                
                ScrollView {
                    DSItemListView(
                        items: $items,
                        editItemSheet: $editItemSheet,
                        tappedItem: $tappedItem,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                        isCategoryView: true,
                        category: category
                    )
                    
                    // Add some space after the items for the button.
                    Color(.clear)
                        .frame(height: 100)
                }
                .padding(.top, 16)
                
                Spacer()
                addItemButton(for: category)
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems(for: category)
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItemSheet(selectedCategory: category, remindersEnabled: false, items: $items)
            }
            .sheet(isPresented: $editItemSheet) {
                EditTappedItemSheet(items: $items, editItemSheet: $editItemSheet, tappedItem: $tappedItem)
            }
            .sheet(isPresented: $showEditCategory) {
                EditCategorySheet(items: $items, category: category)
                //                .presentationDragIndicator(.hidden)
                //                .presentationDetents([.medium])
                    .presentationCornerRadius(44)
                    .onDisappear {
                        showEditCategory = false
                        reviewManager.promptReviewAlert()
                    }
            }
            .confirmationDialog("Delete Category", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        categoryManager.deleteCategory(category: category, items: items)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this category?")
            }
            .alert("Delete Category", isPresented: $showUnableToDelete) {} message: {
                Text("Can't delete category. Category contains existing events.")
            }
        }
    }
        
    func toolbarItems(for category: Category) -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if categoryManager.isCategoryEmpty(category: category, items: items) {
                        showConfirmDelete = true
                    } else {
                        showUnableToDelete = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(colorScheme == .dark ? .primary : accentColor)
                        .imageScale(.large)
                        .accessibilityLabel("Delete Category")
                        .font(.title3)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditCategory = true
                } label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .foregroundColor(colorScheme == .dark ? .primary : accentColor)
                        .imageScale(.large)
                        .accessibilityLabel("Edit Category")
                        .font(.title3)
                }
            }
        }
    }
    
    @ViewBuilder
    func background(for category: Category) -> some View {
        if colorScheme == .dark {
            LinearGradient(
                gradient: .init(colors: [category.color.color.opacity(0.4).darker(by: 0.4), category.color.color.opacity(0.2).darker(by: 0.4)]),
                startPoint: .init(x: 1, y: 0),
                endPoint: .init(x: 0.0001, y: 0)
            )
            .ignoresSafeArea()
            
        } else {
            LinearGradient(
                gradient: .init(colors: [category.color.color.opacity(0.1), category.color.color.opacity(0.2)]),
                startPoint: .init(x: 1, y: 0),
                endPoint: .init(x: 0.0001, y: 0)
            )
            .ignoresSafeArea()
        }
    }
    
    func addItemButton(for category: Category) -> some View {
        VStack {
            Spacer()
            Button {
                showAddItemSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
                .background(LinearGradient(
                    gradient: .init(colors: [category.color.color.opacity(0.8), category.color.color]),
                    startPoint: .init(x: 0.0, y: 0.5),
                    endPoint: .init(x: 0, y: 1)
                ))
                .clipShape(Capsule())
                .shadow(color: items.filter { $0.category.color.color == category.color.color }.count < 5 ? category.color.color : .white, radius: 10, x: 0, y: 5)
            }
        }
    }
}

struct CategoryFilteredView_Previews: PreviewProvider {
    static let mockCategory = Category(id: UUID(), name: "Dreams", emoji: "cloud", color: .marioBlue)
    static let mockItems = [DSItem.placeholderItem()]
    
    static var previews: some View {
        CategoryFilteredView(
            categoryID: mockCategory.id,
            showAddItemSheet: false,
            editItemSheet: false,
            tappedItem: DSItem.placeholderItem(),
            items: .constant(mockItems),
            isDaysDisplayModeDetailed: .constant(false)
        )
        .preferredColorScheme(.dark)
    }
}
