//
//  LastPage.swift
//  DaysSince
//
//  Created by Victoria Petrova on 21/03/2026.
//

import SwiftUI

struct LastPage: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @State var counter: Int = 0
    @State var origin: CGPoint = .zero

    let navigate: (OnboardingScreen) -> Void
    var onComplete: () -> Void = {}
    
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            triggerRippleWithDelay(repeats: 3, delay: 1.5)
                        }
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
                
                CustomButton(action: nextPage, label: "Let's go!", color: .animalCrossingsGreen)
            }
            .padding()
        }
    }
    
    func backgroundColor() -> some View {
        colorScheme == .dark ? Color(.systemBackground) : Color.animalCrossingsGreen.opacity(0.2)
    }
    
    func nextPage() -> Void {
        hasSeenOnboarding = true
        onComplete()
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
