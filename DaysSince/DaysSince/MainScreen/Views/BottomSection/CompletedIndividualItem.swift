//
//  CompletedIndividualItem.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI

struct CompletedIndividualItem: View {
    var item: DaysSinceItem
    @State var displayType: DisplayType = .completed
    
    
    var body: some View {
        Section {
            
            ZStack(alignment: .topTrailing) {
                Spacer()
                ZStack(alignment: .leading) {
                    backgroundColor
                    itemContent
                }
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(RoundedRectangle(cornerRadius: 25).stroke(item.category.color.opacity(0.7), lineWidth: 5))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
                
                completionSymbol
                    .offset(x:-4, y: -4)
            }
        }
    }
    var completionSymbol: some View {
        Image(systemName: "checkmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, alignment: .topTrailing)
            .foregroundColor(Color.green)
            .background(.white)
            .clipShape(Circle())
//            .frame(width: 300)
//            .offset()
    }
    var nameText: some View {
        Text(item.name)
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundColor(item.category.color.opacity(0.7))
    }
    
    var completedDaysAgoText: some View {
        VStack {
            if displayType == .completed {
                Text("COMPLETED")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color.green.opacity(0.5))
                
                Text("\(item.completedDaysAgo)")
                    .font(.system(size:50, design: .rounded))
                    .bold()
                    .foregroundColor(item.category.color.opacity(0.7))
                
                Text("days ago")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(item.category.color.opacity(0.7))
            } else {
                Text("\(item.daysAgo)")
                    .font(.system(size:50, design: .rounded))
                    .bold()
                    .foregroundColor(item.category.color.opacity(0.7))
                
                Text("days ago")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(item.category.color.opacity(0.7))
            }
        }
        .onTapGesture{withAnimation{changeDisplayType()}}
       
    }
    
    @ViewBuilder
    var backgroundColor: some View {
        Color.white
    }
    
    var itemContent: some View {
        HStack {
            nameText
            Spacer()
            completedDaysAgoText
        }
        .padding()
    }
    
    enum DisplayType {
        static var allCases: [DisplayType] = [
            .started, .completed
        ]

        case started
        case completed
        
        var state: String {
            switch self {
            case .started:
                return "Days Since Started"
            case .completed:
                return "Days Since Completed"
            }
        }
    }
    
    func changeDisplayType() {
        if displayType == .completed {
            displayType = .started
        } else if displayType == .started {
            displayType = .completed
        }
    }
    
}

struct CompletedIndividualItem_Previews: PreviewProvider {
    static var previews: some View {
        CompletedIndividualItem(item: DaysSinceItem.placeholderItem())
    }
}
