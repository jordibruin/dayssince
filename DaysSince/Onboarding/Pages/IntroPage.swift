//
//  IntroPage.swift
//  DaysSince
//
//  Created by Victoria Petrova on 03/05/2025.
//

import SwiftUI

struct IntroPage: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    
    let navigate: (OnboardingScreen) -> Void
    
    var body: some View {
        ZStack {
            backgroundColor()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                Image("sticker")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 340)
                    .modifier(RippleEffect(at: origin, trigger: counter))
                    .onAppear {
                        origin = .zero
                        triggerRippleWithDelay(repeats: 3, delay: 1.5)
                    }
                    .onTapGesture { location in
                        origin = location
                        counter += 1
                    }
                
                Text("Days Since")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .foregroundColor(.animalCrossingsGreen)
                
                Text("Track what matters, wherever life takes you!")
                    .font(.system(.title3, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                
                Spacer()
                
                CustomButton(action: nextPage, label: "Get Started", color: .animalCrossingsGreen)
            }
            .padding()
        }
    }
    
    
    func backgroundColor() -> some View {
        colorScheme == .dark ? Color(.systemBackground) : Color.animalCrossingsGreen.opacity(0.2)
    }
    
    func nextPage() -> Void {
        print("next page")
        navigate(.screen2)
    }
    
    func triggerRippleWithDelay(repeats: Int, delay: TimeInterval) {
        for i in 0..<repeats {
            DispatchQueue.main.asyncAfter(deadline: .now() + (delay * Double(i))) {
                counter += 1
            }
        }
    }
}

#Preview {
    IntroPage(navigate: { _ in })
}
