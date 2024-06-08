//
//  CategoryFilteredView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/8/22.
//

import SwiftUI

struct CategoryFilteredView: View {
    @Environment(\.colorScheme) var colorScheme

    var category: Category

    @State var showAddItemSheet: Bool
    @State var editItemSheet: Bool
    @State var tappedItem: DSItem = .placeholderItem()
    @State var showConfirmDelete = false
    @State var showUnableToDelete = false

    @Binding var items: [DSItem]
    @Binding var isDaysDisplayModeDetailed: Bool

    @EnvironmentObject var categoryManager: CategoryManager

    var accentColor: Color { category.color.color }

    var body: some View {
        ZStack {
            background

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
            addItemButton
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            toolbarItems
        })
        .sheet(isPresented: $showAddItemSheet) {
            AddItemSheet(selectedCategory: category, remindersEnabled: false, items: $items)
        }
        .sheet(isPresented: $editItemSheet) {
            EditTappedItemSheet(items: $items, editItemSheet: $editItemSheet, tappedItem: $tappedItem)
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

    var toolbarItems: some ToolbarContent {
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
                        .font(.title2)
                }
            }
        }
    }

    @ViewBuilder
    var background: some View {
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

    var addItemButton: some View {
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
    static var previews: some View {
        CategoryFilteredView(
            category: Category.placeholderCategory(),
            showAddItemSheet: false,
            editItemSheet: false,
            tappedItem: DSItem.placeholderItem(),
            items: .constant([DSItem.placeholderItem()]),
            isDaysDisplayModeDetailed: .constant(false)
        )
        .preferredColorScheme(.dark)
    }
}
