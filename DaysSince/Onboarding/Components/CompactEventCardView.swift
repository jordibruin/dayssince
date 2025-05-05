//
//  CompactEventView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import SwiftUI


struct CompactEventCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var event: EventCardModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            backgroundColor
            itemContent
        }
        .clipShape(roundedShape)
        .overlay(
            roundedShape
                .stroke(borderColor, lineWidth: 6)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? event.color.lighter(by: 0.04) : .white
    }

    private var borderColor: Color {
        colorScheme == .dark ? event.color.darker() : event.color
    }

    private var roundedShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 23)
    }
    
    var itemContent: some View {
        VStack(alignment: .leading) {
            if event.name != "No event" {
                daysAgoText
            }

            Spacer()
            nameText
        }
        .padding()
    }
    
    var nameText: some View {
        Text(event.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
            .minimumScaleFactor(0.6) // Text fits in widget
    }
    
    @ViewBuilder
    var daysAgoText: some View {
        if true { // TODO: make this conditional on isDetailedTimeDisplayMode if the view will be reused
            HStack(alignment: .top, spacing: 6) {
                if dateComponents.year ?? 0 > 0 {
                    timeUnitView(value: dateComponents.year!, unit: "year", useCaption: true)
                }

                if (dateComponents.month ?? 0 > 0) || (dateComponents.year ?? 0 > 0) {
                    timeUnitView(value: dateComponents.month!, unit: "month", useCaption: dateComponents.year! > 0)
                }

                timeUnitView(value: dateComponents.day!, unit: "day", useCaption: dateComponents.year! > 0)
            }
            .padding(.trailing, 0)
        } else {
            VStack(alignment: .center) {
                Text("\(event.daysNumber)")
                    .font(.system(event.daysNumber > 9999 ? .title3 : .title2, design: .rounded))
                    .bold()
                    .foregroundColor(textColor)

                Text("days")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(textColor)
            }
            .frame(width: widthForDayNumber(event.daysNumber))
        }
    }

    private var textColor: Color {
        colorScheme == .dark ? .primary : event.color
    }

    private var dateComponents: DateComponents {
        Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Calendar.current.startOfDay(for: event.dateLastDone),
            to: Calendar.current.startOfDay(for: Date())
        )
    }

    @ViewBuilder
    private func timeUnitView(value: Int, unit: String, useCaption: Bool = false) -> some View {
        VStack(alignment: .center) {
            Text("\(value)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(textColor)

            Text(value == 1 ? unit : "\(unit)s")
                .font(.system(useCaption ? .caption : .body, design: .rounded))
                .foregroundColor(textColor)
        }
    }

    private func widthForDayNumber(_ value: Int) -> CGFloat {
        switch value {
        case 0..<100: return 40
        case 100..<1000: return 50
        default: return 70
        }
    }
    
}

#Preview {
    CompactEventCardView(event: EventCardModel.mock())
}
