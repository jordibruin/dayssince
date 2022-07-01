//
//  ContactItemView.swift
//  Supporter
//
//  Created by Jordi Bruin on 04/12/2021.
//

import SwiftUI

struct ContactItemView: View {
    
    @Environment(\.openURL) var openURL
    
    let item: SupportContactItem
    
    var body: some View {
        
        Button {
            if let url = URL(string: item.url) {
                openURL(url)
            } else {
                print("Not a valid url")
            }
        } label: {
            HStack {
                item.color.color
                    .frame(width: 30, height: 30)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: item.imageName)
                            .foregroundColor(.white)
                            .font(.title3)
                    )
                    .padding(.leading, -10)

                Text(item.title)
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(Design.listTitleColor)

                Spacer()
            }
        }
    }
}
