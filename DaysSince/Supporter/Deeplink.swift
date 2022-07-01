//
//  Deeplink.swift
//  Posture Pal
//
//  Created by Jordi Bruin on 04/03/2022.
//

import SwiftUI

struct Deeplink: View {
    
    let id: Int
    
    @State var item: SupportPageable?
    @Environment(\.dismiss) var dismiss
    @State var activePage: Int = 0
    @StateObject var support = SupportFetcher()
    
    var body: some View {
        NavigationView {
            Group {
                if item != nil {
                    tabView()
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .font(.title3)
                    .foregroundColor(.primary)
                    .opacity(0.7)
                }
            })
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: support.retrievedSupport, perform: { newValue in
            if let item = support.allItems.first(where: { $0.id == self.id}) {
                self.item = item
            } else {
                print("ID NOT FOUND! Dismiss and throwerror ")
//                Analytics().hit(.openedSupport(id))
                dismiss()
            }
        })
    }
    
    @ViewBuilder
    func tabView() -> some View {
        if item!.supportPages.isEmpty {
            Color.clear
        } else {
            TabView(selection: $activePage) {
                ForEach(item!.supportPages) { page in
                    SupportItemPageView(page: page)
                }
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.bottom))
        }
    }
}

struct Deeplink_Previews: PreviewProvider {
    static var previews: some View {
        Deeplink(id: 4)
    }
}

