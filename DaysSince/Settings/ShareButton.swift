//
//  ShareButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/30/22.
//

import SwiftUI

struct ShareButton: View {
    
    @State var showShare = false
    
    var body: some View {
        
        Button {
            showShare = true
        } label: {
            HStack {
                LinearGradient(colors: [Color.workColor, Color.workColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                    )
                    .padding(.leading, -10)
                
                text
                    
                Spacer()
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.title2)
                    .foregroundColor(Color.workColor.darker())
                    .opacity(0.5)
            }
        }
        .foregroundColor(.primary)
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [URL(string: "https://twitter.com/DaysSince_App")!])
        }
    }
    
    var text: some View {
        Text("Share Days Since")
            .font(.system(.body, design: .rounded))
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton()
    }
}

struct ShareSheet : UIViewControllerRepresentable {
    var items : [Any]
    
    func makeUIViewController(context: Context) -> some UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}
