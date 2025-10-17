//
//  PayWallScreen.swift
//  DaysSince
//
//  Created by Victoria Petrova on 17/10/2025.
//

import SwiftUI
import Defaults

struct PayWallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var entitlements: Entitlements
    @Default(.mainColor) var mainColor

    @State private var isLoading: Bool = false
    let inOnboarding: Bool
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            mainColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
               ScrollView {
                   HStack {
                       VStack(spacing: 8) {
                           Text("Days Since Pro")
                               .font(.system(size: 40, weight: .heavy, design: .rounded))
                               .foregroundColor(.white)

//                           Text("Unlock all pro features.")
//                               .font(.system(.body, design: .rounded))
//                               .foregroundColor(.secondary)
                       }
                       
                       Spacer()
                       
                      
                       Button {
                           if inOnboarding { hasSeenOnboarding = true }
                           dismiss()
                       } label: {
                           Image(systemName: "xmark.circle.fill")
                               .font(.title)
                               .foregroundColor(.white)
                       }
                   }
                   .padding([.horizontal, .top])
                   
                   ProBenefitsView()
                       .zIndex(20)
                       .padding(.bottom, 50)
               }
               .overlay(
                    VStack(spacing: 0) {
                        Spacer()

                        LinearGradient(colors: [
                          mainColor,
                          mainColor.opacity(0)
                        ],
                         startPoint: .bottom,
                         endPoint: .top
                        )
                        .frame(height: 70)
                        .allowsHitTesting(false)
                    }
                )
                  
                VStack {
                    if entitlements.isPro {
                        Label("You already own Pro", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .padding(.top, 8)
                    } else {
                        pricingArea
                    }
                    
                    TermsAndFriends()
                }
                .padding(.top, 8)
                .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
                .onChange(of:entitlements.isPro) { newValue in
                    if newValue {
                        hasSeenOnboarding = true   
                        dismiss()
                    }
                }
            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(mainColor.darker())
//                            .accessibilityLabel("Close")
//                    }
//                }
//            }
            .task {
                if storeManager.proProduct == nil {
                    await storeManager.requestProducts()
                }
            }
        }
        .accentColor(mainColor.darker())
    }

    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Unlimited customization", systemImage: "paintpalette.fill")
            Label("More themes and icons", systemImage: "square.grid.2x2.fill")
            Label("Future Pro features", systemImage: "sparkles")
        }
        .font(.system(.body, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var pricingArea: some View {
        if let product = storeManager.proProduct {
            Button {
                Task {
                    await storeManager.purchasePro()
                }
            } label: {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .opacity(storeManager.isPurchasing ? 1 : 0)
                        .frame(width: 16, height: 16)
                    Text("Unlock for \(product.displayPrice)")
                        .bold()
                }
                .animation(.easeInOut(duration: 0.2), value: storeManager.isPurchasing)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(mainColor)
            .padding(.horizontal)

            Button {
                Task { await storeManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        } else {
            VStack(spacing: 12) {
                ProgressView()
                Button {
                    Task { await storeManager.requestProducts() }
                } label: {
                    Text("Retry loading price")
                }
            }
        }

        if let error = storeManager.purchaseErrorMessage {
            Text(error)
                .font(.footnote)
                .foregroundColor(.red)
                .padding(.top, 4)
                .accessibilityLabel("Purchase error: \(error)")
        }
    }
}

#Preview {
    PayWallScreen(inOnboarding: false)
}


import StoreKit

struct TermsAndFriends: View {
    
//    @Binding var showAllPlans: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
//    
//    @State var showAllFeatures = false
    
    var body: some View {
        HStack(spacing: 12) {
            
//            Button {
//                showAllFeatures.toggle()
//            } label: {
//                Text("Features")
//                    .font(.system(.body, design: .rounded).weight(.medium))
//            }
//            .sheet(isPresented: $showAllFeatures) {
//                AllFeaturesScreen()
//            }
            
//            Button {
//                showAllPlans.toggle()
//            } label: {
//                Text(showAllPlans ? "Hide" : "All Plans")
//                    .font(.system(.body, design: .rounded).weight(.medium))
//            }
//            Divider()
//                .frame(height: 10)
            
            Link(destination: URLConstants.termsOfUseURL) {
                Text("Privacy Policy")
                    .font(.system(.body, design: .rounded).weight(.medium))
            }
            
//            Divider()
//                .frame(height: 10)
            
            
//            Button {
//                Task {
//                    let result = try? await AppStore.sync()
//                    print(result)
//                }
//            } label: {
//                Text("Restore")
//                    .font(.system(.body, design: .rounded).weight(.medium))
//            }
        }
        .foregroundColor(.primary)
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        
    }
}
