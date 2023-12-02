//
//  Introduction.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//

import SwiftUI

struct Introduction: View {
    @Binding var selectedPage: Int

    @State var titles = [
        "Welcome ",
        "Keep Track",
        "Build",
    ]

    @State var subTitles = [
        "to Days Since!",
        "of the things that matter to you the most",
        "habits and memories",
    ]

    @State var colors = [
        Color.workColor,
        Color.lifeColor,
        Color.hobbiesColor,
    ]

    @State var currentIndex: Int = 2
    @State var titleText: [AnimateText] = []
    @State var subTitleAnimation: Bool = false
    @State var endAnimation = false

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                let size = proxy.size
                Color.white

                LinearGradient(colors: [colors[currentIndex].opacity(0.1), colors[currentIndex].opacity(0.6)], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                HStack(spacing: 0) {
                    ForEach(titleText) { text in
                        Text(text.text)
                            .offset(y: text.offset)
                    }
                    .font(.largeTitle.bold())
                }
                .offset(y: endAnimation ? -100 : 0)
                .opacity(endAnimation ? 0 : 1)

                Text(subTitles[currentIndex])
                    .opacity(0.7)
                    .offset(y: !subTitleAnimation ? 64 : 0)
                    .offset(y: endAnimation ? -100 : 0)
                    .opacity(endAnimation ? 0 : 1)

                nextButton
            }
        }
        .onAppear(perform: {
            currentIndex = 0
        })
        .onChange(of: currentIndex) { _ in
            getSpilitedText(text: titles[currentIndex]) {
                withAnimation(.easeInOut(duration: 1.8)) {
                    endAnimation.toggle()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    titleText.removeAll()
                    subTitleAnimation.toggle()
                    endAnimation.toggle()

                    withAnimation(.easeInOut(duration: 0.6)) {
                        if currentIndex < (titles.count - 1) {
                            currentIndex += 1
                        } else {
                            currentIndex = 0
                        }
                    }
                }
            }
        }
    }

    func getSpilitedText(text: String, completion: @escaping () -> Void) {
        for (index, character) in text.enumerated() {
            titleText.append(AnimateText(text: String(character)))

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    titleText[index].offset = 0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.02) {
            withAnimation(.easeInOut(duration: 0.5)) {
                subTitleAnimation.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                completion()
            }
        }
    }

    var nextButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation {
                selectedPage += 1
            }
        } label: {
            HStack {
                Spacer()

                Text("Create your first event")
                    .font(.system(.title2))
                    .bold()
                    .foregroundColor(.white)

                Spacer()
            }
            .contentShape(RoundedRectangle(cornerRadius: 28))
        }
        .padding()
        .background(colors[currentIndex])
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
}

struct Introduction_Previews: PreviewProvider {
    static var previews: some View {
        Introduction(selectedPage: .constant(0))
    }
}
