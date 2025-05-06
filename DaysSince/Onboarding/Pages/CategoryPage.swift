//
//  CategoryPage.swift
//  DaysSince
//
//  Created by Victoria Petrova on 03/05/2025.
//

import SwiftUI

struct CategoryPage: View {
    @State private var counter = 0
    @State private var origin: CGPoint = .zero
    @State private var selectedCategories: Set<Category> = []
    @State private var tappedCategory: Category?

    let navigate: (OnboardingScreen) -> Void
    private static let gridLayout = Array(repeating: GridItem(.flexible(minimum: 100), spacing: 10), count: 3)

    private var optionalCategories: [Category] {
        Category.sampleList
    }

    var body: some View {
        VStack {
            ProgressBar(progress: 2/8)
                .padding()
            header
            categoryGrid
            Spacer()
            footer
        }
        CustomButton(action: nextPage, label: "Continue", color: .animalCrossingsGreen)
    }

    private var header: some View {
        Text("What parts of life do you want to track?")
            .font(.system(.title3, design: .rounded))
            .bold()
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: Self.gridLayout) {
            ForEach(optionalCategories) { category in
                CategorySelectionView(
                    category: category,
                    isSelected: selectedCategories.contains(category),
                    isTapped: tappedCategory == category,
                    onTap: {
                        tappedCategory = category
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            tappedCategory = nil
                        }
                        toggleSelection(of: category)
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var footer: some View {
        HStack {
            Image("sunny")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 180)
                .shadow(radius: 4, x: 4, y: 6)
                .modifier(RippleEffect(at: origin, trigger: counter))
                .onAppear {
                    origin = .zero
                    counter += 1
                }
                .onTapGesture { location in
                    origin = location
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        counter += 1
                    }
                }

            ChatBubble(direction: .left) {
                Text("Choose all categories that matter right now. You can always change later!")
                    .padding(20)
                    .foregroundColor(.primary)
                    .background(Color(.secondarySystemFill))
            }
            .offset(y: -40)
        }
    }

    private func toggleSelection(of category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func nextPage() {
        print("next page")
        navigate(.screen3)
    }
}


#Preview {
    CategoryPage(navigate: { _ in})
}

struct CategorySelectionView: View {
    let category: Category
    let isSelected: Bool
    let isTapped: Bool
    let onTap: () -> Void

    var body: some View {
        MenuBlockView(category: category, items: .constant([]))
            .scaleEffect(isTapped ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.3), value: isTapped)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                    .font(.title3)
                    .padding(8)
                    .shadow(color: .blue.opacity(0.1), radius: 5)
                    .opacity(isSelected ? 1.0 : 0.0)
            }
            .aspectRatio(1.0, contentMode: .fit)
            .onTapGesture(perform: onTap)
    }
}
