//
//  FeaturesPage.swift
//  DaysSince
//
//  Created by Victoria Petrova on 21/03/2026.
//

import SwiftUI

struct FeaturesPage: View {
    @Environment(\.colorScheme) var colorScheme
    let navigate: (OnboardingScreen) -> Void
    
    @State private var counter = 0
    @State private var origin: CGPoint = .zero
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ProgressBar(progress: 7/8)
                    .padding()
                headerText

                ScrollView {
                    featureList
                        .padding(.bottom, 50)
                }
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()
                        LinearGradient(
                            colors: [backgroundColor, backgroundColor.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 50)
                        .allowsHitTesting(false)
                    }
                )

                footer
                CustomButton(
                    action: nextPage,
                    label: "Exciting!",
                    color: .animalCrossingsGreen
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }

    func nextPage() -> Void {
        navigate(.screen8)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color.animalCrossingsGreen.lighter(by: 0.8)
    }
    
    var headerText: some View {
        Text("Features")
            .font(.system(.title3, design: .rounded))
            .bold()
            .padding(.bottom, 16)
    }
    
    var featureList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(FeatureItem.all) { feature in
                FeatureRow(text: feature.text, symbol: feature.symbol)
            }
        }
        .padding([.horizontal, .bottom])
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        counter += 1
                    }
                }
                .onTapGesture { location in
                    origin = location
                    counter += 1
                }
        }
    }

}

#Preview {
    FeaturesPage(navigate: { _ in })
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let text: String
    let symbol: String

    static let all: [FeatureItem] = [
        FeatureItem(text: "Create events to track time", symbol: "calendar"),
        FeatureItem(text: "Stay alert with home and lockscreen widgets", symbol: "widget.small"),
        FeatureItem(text: "Receive daily, weekly, and monthly reminders", symbol: "exclamationmark.message"),
        FeatureItem(text: "Organize your events in categories", symbol: "square.stack"),
        FeatureItem(text: "Customize your view with colors and themes", symbol: "paintpalette"),
        FeatureItem(text: "Pick your app icon from the extra icons", symbol: "app.badge"),
        FeatureItem(text: "Suggest new features or report bugs in the settings", symbol: "ellipsis.message"),
    ]
}

struct FeatureRow: View {
    let text: String
    let symbol: String

    var body: some View {
        HStack {
            LinearGradient(colors: [.workColor, .workColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: 40, height: 40)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: symbol)
                        .bold()
                        .font(.title2)
                        .foregroundColor(.white)
                )

            Text(text)
                .multilineTextAlignment(.leading)
                .font(.system(.title3))
                .bold()

            Spacer()
        }
        .padding(8)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemFill))
        .cornerRadius(8)
        .foregroundColor(.primary)
    }
}
