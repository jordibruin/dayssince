//
//  ProBenefitsView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 17/10/2025.
//

import SwiftUI
import Defaults


struct ProBenefitsView: View {
    
    @Default(.mainColor) var mainColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProFeatureView(color: mainColor, emoji: "🔮", symbol: "calendar.badge.plus", featureText: "Unlimited Events")
            ProFeatureView(color: mainColor, emoji: "🧺", symbol: "rectangle.3.group", featureText: "Unlimited Categories")
            ProFeatureView(color: mainColor, emoji: "📸", symbol: "paintpalette.fill", featureText: "Custom Colors")
            ProFeatureView(color: mainColor, emoji: "✅", symbol: "app.badge", featureText: "Extra App Icons")
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    ProBenefitsView()
}
