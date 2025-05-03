//
//  DSItemListView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI
import WidgetKit

struct DSItemListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var reviewManager: ReviewManager

    @Binding var items: [DSItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem
    @Binding var isDaysDisplayModeDetailed: Bool

    @State var showingDeleteAlert: Bool = false
    @State var itemToDelete: DSItem? = nil

    var isCategoryView: Bool = false
    var category: Category?

    var body: some View {
        if isCategoryView {
            categorizedItemListView(items: $items)
        } else {
            itemListView(items: $items)
        }
    }

    func categorizedItemListView(items: Binding<[DSItem]>) -> some View {
        ForEach(items.wrappedValue.filter { $0.category == category }, id: \.id) { item in
            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                itemID: item.id,
                items: items,
                colored: true
            )
        }
        .padding(.horizontal)
    }

    @AppStorage("selectedSortType") var selectedSortType: SortType = .daysAscending

    func itemListView(items: Binding<[DSItem]>) -> some View {
        ForEach(items.wrappedValue.sorted { selectedSortType.sort(itemOne: $0, itemTwo: $1) }) { item in

            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                itemID: item.id,
                items: items,
                colored: false
            )
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 22.2))
            .contextMenu {
                Button {
                    if let index = items.wrappedValue.firstIndex(where: { $0.id == item.id }) {
                        changeDateTo(Date.now, itemIndex: index)
                    }
                } label: {
                    Label("Today", systemImage: "calendar")
                }

                Button {
                    if let index = items.wrappedValue.firstIndex(where: { $0.id == item.id }) {
                       changeDateTo(Date().dayBefore, itemIndex: index)
                    }
                } label: {
                    Label("Yesterday", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    showingDeleteAlert = true
                    itemToDelete = items.wrappedValue.first { $0.id == item.id }
                } label: {
                    Label("Delete Event", systemImage: "trash")
                        .tint(.red)
                }
            }
        }
        .padding(.horizontal)
        .confirmationDialog(
            Text("Are you sure you want to delete this event?"),
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    if let item = itemToDelete {
                        deleteEvent(item)
                    }
                    itemToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
        }
    }

    func changeDateTo(_ date: Date, itemIndex: Int) {
         guard items.indices.contains(itemIndex) else {
             print("Error: Index out of bounds.")
             return
         }
         
        withAnimation {
            let item = items[itemIndex]
            print("Change date to \(date) for item \(item.name)")

            items[itemIndex].dateLastDone = date

            if items[itemIndex].remindersEnabled {
                notificationManager.deleteReminderFor(item: item)
                notificationManager.addReminderFor(item: items[itemIndex])
            }
            
            reviewManager.promptReviewAlert()
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    func deleteEvent(_ item: DSItem) {
        guard let itemIndex = getItemIndex(item) else {
             print("Error: Item not found for deletion.")
             return
         }
        
        withAnimation {
            print("🗑 Delete event \(item.name)")

            notificationManager.deleteReminderFor(item: item)

            items.remove(at: itemIndex)
        }
    }

    func getItemIndex(_ item: DSItem) -> Int? {
        print("Looking for index of tapped item.")
        return items.firstIndex(where: { $0.id == item.id })
    }
}

struct NormalItemsList_Previews: PreviewProvider {
    static var previews: some View {
        DSItemListView(items: .constant([]), editItemSheet: .constant(false), tappedItem: .constant(.placeholderItem()), isDaysDisplayModeDetailed: .constant(false), category: Category.placeholderCategory())
          .environmentObject(NotificationManager())
          .environmentObject(ReviewManager())
    }
}
