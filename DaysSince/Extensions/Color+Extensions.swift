//
//  Color+Extensions.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/8/22.
//

import Foundation
import SwiftUI

extension Color {
    static let workColor = Color("workColor")
    static let lifeColor = Color("lifeColor")
    static let hobbiesColor = Color("hobbiesColor")
    static let healthColor = Color("healthColor")
    static let backgroundColor = Color("backgroundColor")
    static let peachLightPink = Color("peachLightPink")
    static let peachDarkPink = Color("peachDarkPink")
    static let marioBlue = Color("marioBlue")
    static let marioRed = Color("marioRed")
    static let zeldaGreen = Color("zeldaGreen")
    static let zeldaYellow = Color("zeldaYellow")
    static let animalCrossingsBrown = Color("animalCrossingsBrown")
    static let animalCrossingsGreen = Color("animalCrossingsGreen")

    public func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}

extension UIColor {
    func mix(with color: UIColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}
