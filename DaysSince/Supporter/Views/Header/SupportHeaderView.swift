//
//  SupportHeaderView.swift
//  Supporter
//
//  Created by Jordi Bruin on 29/11/2021.
//

import SwiftUI

struct SupportHeaderView: View {
    
    let item: HeaderItem
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            item.color.color
                .overlay(
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            if #available(iOS 15.0, *) {
                                Image(systemName: item.imageName)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: item.imageName)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(12)
                )
            Text(item.title)
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .padding()
                .foregroundColor(.white)
                .padding(.trailing, 40)
                .multilineTextAlignment(.leading)
        }
//        }
        .buttonStyle(FlatLinkStyle())

    }
}

struct SupportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SupportHeaderView(item: HeaderItem.example)
    }
}

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct SupportDetailScreen: View {
    
    let title: String
    let description: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(.title, design: .rounded))
                    .bold()
                
                Text(description)
                    .font(.system(.body, design: .rounded))
                
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    
}


