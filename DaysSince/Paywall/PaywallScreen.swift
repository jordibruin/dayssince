//
//  PaywallScreen.swift
//  DaysSince
//
//  Created by Victoria Petrova on 28/03/2026.
//

import Defaults
import StoreKit
import SwiftUI

struct PaywallScreen: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @Default(.mainColor) var mainColor

    let isDismissable: Bool

    @State private var selectedProductID: String? = "dayssince.weekly"
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        featureList
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
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

                VStack(spacing: 10) {
                    pricingCards
                    bottomSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .background(Color(UIColor.systemBackground))
            }

            dismissButton
        }
        .interactiveDismissDisabled(!isDismissable)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : mainColor.lighter(by: 0.74)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image("calendar-purple-image")
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(18)

            Text("Days Since Pro")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundColor(mainColor)

            Text("Get the most out of your tracking experience.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Features

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(FeatureItem.all) { feature in
                FeatureRow(
                    text: feature.text,
                    symbol: feature.symbol
                )
            }
        }
    }

    // MARK: - Pricing Cards

    private var pricingCards: some View {
        VStack(spacing: 10) {
            if let weekly = subscriptionManager.product(for: "dayssince.weekly") {
                PricingCard(
                    product: weekly,
                    billedAmount: weekly.displayPrice,
                    period: "week",
                    introLabel: subscriptionManager.isEligibleForIntro ? introOfferLabel(for: weekly) : nil,
                    badge: "Most Popular",
                    isProminent: true,
                    isSelected: selectedProductID == weekly.id,
                    accentColor: mainColor
                )
                .onTapGesture { selectedProductID = weekly.id }
            }

            if let monthly = subscriptionManager.product(for: "dayssince.monthly") {
                PricingCard(
                    product: monthly,
                    billedAmount: monthly.displayPrice,
                    period: "month",
                    introLabel: subscriptionManager.isEligibleForIntro ? introOfferLabel(for: monthly) : nil,
                    badge: nil,
                    isProminent: false,
                    isSelected: selectedProductID == monthly.id,
                    accentColor: mainColor
                )
                .onTapGesture { selectedProductID = monthly.id }
            }

            if let annual = subscriptionManager.product(for: "dayssince.annual") {
                PricingCard(
                    product: annual,
                    billedAmount: annual.displayPrice,
                    period: "year",
                    introLabel: subscriptionManager.isEligibleForIntro ? introOfferLabel(for: annual) : nil,
                    badge: "Best Value",
                    isProminent: false,
                    isSelected: selectedProductID == annual.id,
                    accentColor: mainColor
                )
                .onTapGesture { selectedProductID = annual.id }
            }
        }
    }

    private func introOfferLabel(for product: Product) -> String? {
        guard let intro = product.subscription?.introductoryOffer else { return nil }

        let period = intro.period
        let count = intro.periodCount

        let unitName: String
        switch period.unit {
        case .day:
            unitName = period.value == 7 ? (count == 1 ? "week" : "weeks") : (count == 1 ? "day" : "days")
        case .week:
            unitName = count == 1 ? "week" : "weeks"
        case .month:
            unitName = count == 1 ? "month" : "months"
        case .year:
            unitName = count == 1 ? "year" : "years"
        @unknown default:
            return nil
        }

        if intro.paymentMode == .freeTrial {
            return "Free for \(count) \(unitName)"
        }

        let periodLabel = period.value == 7 ? "week" : "\(period.value) \(period.unit)"
        return "\(intro.displayPrice)/\(periodLabel) for \(count) \(unitName)"
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        VStack(spacing: 6) {
            if let error = errorMessage {
                Text(error)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.red)
            }

            Button {
                Analytics.send(.proStartPurchase)
                Task { await purchaseSelected() }
            } label: {
                HStack {
                    Spacer()
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Continue")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(selectedProductID != nil ? mainColor : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(selectedProductID == nil || isPurchasing)
            .padding(.horizontal, 12)

            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    if subscriptionManager.isSubscribed {
                        dismiss()
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Text("Auto-renews unless cancelled. Cancel anytime in Settings.")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("and")
                    .foregroundColor(.secondary.opacity(0.6))
                Link("Privacy Policy", destination: URL(string: "https://www.notion.so/jordibruin/Days-Since-Privacy-a5e0d3b91d6b41359af6613b94dc7778")!)
            }
            .font(.system(.caption2, design: .rounded))
            .padding(.bottom, 0)
        }
    }

    // MARK: - Dismiss Button

    private var dismissButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
            Spacer()
        }
    }

    // MARK: - Purchase Action

    private func purchaseSelected() async {
        guard let id = selectedProductID,
              let product = subscriptionManager.product(for: id) else { return }

        isPurchasing = true
        errorMessage = nil

        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                Analytics.send(isDismissable ? .proPurchased : .proPurchasedInOnboarding)
                dismiss()
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }

        isPurchasing = false
    }
}

// MARK: - Pricing Card

private struct PricingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let product: Product
    let billedAmount: String
    let period: String
    var introLabel: String? = nil
    let badge: String?
    let isProminent: Bool
    let isSelected: Bool
    let accentColor: Color

    private var cardBackground: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.workColor.lighter(by: 0.82)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(product.displayName)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.primary)
                    if let badge {
                        Text(badge)
                            .font(.system(.caption2, design: .rounded))
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isProminent ? accentColor : Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                if let introLabel {
                    Text(introLabel)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text(billedAmount)
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.primary)
                Text("/\(period)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? accentColor : Color.clear,
                    lineWidth: isSelected ? 2 : 0
                )
        )
    }
}

#Preview {
    PaywallScreen(isDismissable: true)
        .environmentObject(SubscriptionManager())
}
