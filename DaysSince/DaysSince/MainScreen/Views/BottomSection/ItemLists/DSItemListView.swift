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
            categorizedItemListView
        } else {
            itemListView
        }
    }

    var categorizedItemListView: some View {
        ForEach(self.items.filter { $0.category == category }, id: \.id) { item in
            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                item: item,
                colored: true
            )
        }
        .padding(.horizontal)
    }

    @AppStorage("selectedSortType") var selectedSortType: SortType = .daysAscending

    var itemListView: some View {
        ForEach(self.items.sorted { selectedSortType.sort(itemOne: $0, itemTwo: $1) }) { item in

            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                item: item,
                colored: false
            )
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 22.2))
            .contextMenu {
                Button {
                    changeDateTo(Date.now, item: item)
                } label: {
                    Label("Today", systemImage: "calendar")
                }

                Button {
                    changeDateTo(Date().dayBefore, item: item)
                } label: {
                    Label("Yesterday", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    showingDeleteAlert = true
                    itemToDelete = item
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
                    deleteEvent(itemToDelete!)
                }
            }
        }
    }

    func changeDateTo(_ date: Date, item: DSItem) {
        withAnimation {
            print("Change date to \(date) for item \(item.name)")

            let itemIndex = getItemIndex(item)

            items[itemIndex].dateLastDone = date

            // If the event's reminders are enabled, update them
            if items[itemIndex].remindersEnabled {
                notificationManager.deleteReminderFor(item: items[itemIndex])
                notificationManager.addReminderFor(item: items[itemIndex])
            }
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "SooseeWidget")
    }

    func deleteEvent(_ item: DSItem) {
        withAnimation {
            print("🗑 Delete event \(item.name)")

            let itemIndex = getItemIndex(item)

            // Remove notifications before deleting the event
            notificationManager.deleteReminderFor(item: item)

            items.remove(at: itemIndex)
        }
    }

    func getItemIndex(_ item: DSItem) -> Int {
        print("Looking for index of tapped item.")
        return items.firstIndex(where: { $0.id == item.id })!
    }
}

struct NormalItemsList_Previews: PreviewProvider {
    static var previews: some View {
        DSItemListView(items: .constant([]), editItemSheet: .constant(false), tappedItem: .constant(.placeholderItem()), isDaysDisplayModeDetailed: .constant(false), category: Category.placeholderCategory())
    }
}
