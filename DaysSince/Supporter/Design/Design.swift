//
//  Design.swift
//  SnoozeSupport
//
//  Created by Jordi Bruin on 31/12/2021.
//

import Foundation
import SwiftUI

struct Design {

     // MARK: DEFAULTS
    // The background color for the entire support screen
    // Note: right now this requires a hack by uncommenting the init in
    // Supportscreen. Has not been tested well enough yet and may
    // have side effects in other parts of your app
//    static let listBackgroundColor: Color = Color(.systemGroupedBackground)
    
    // The color for the detail page background
//    static let backgroundColor: Color = Color(.systemBackground)

    // The colors of the individual cells in the list
//    static let listRowBackgroundColor: Color = Color(.systemBackground)

    // The color used for the titles in the items on the support screen
//    static let listTitleColor: Color = .primary

    // The color used for the subtitle in the highlighteditem view
    // as well as the text in the Toggle Dropdowns for FAQ items
//    static let listTextColor: Color = .primary
    
    
    // ----------------------
    // CUSTOMIZE COLORS BELOW
    // ----------------------
    
    // The background color for the entire support screen
    // Note: right now this requires a hack by uncommenting the init in
    // Supportscreen. Has not been tested well enough yet and may
    // have side effects in other parts of your app
    static let listBackgroundColor: Color = Color(.systemGroupedBackground)
    
    // The color for the detail page background
    static let backgroundColor: Color = Color(.systemBackground)

    // The colors of the individual cells in the list
    static let listRowBackgroundColor: Color = Color(.secondarySystemGroupedBackground)

    // The color used for the titles in the items on the support screen
    static let listTitleColor: Color = .primary

    // The color used for the subtitle in the highlighteditem view
    // as well as the text in the Toggle Dropdowns for FAQ items
    static let listTextColor: Color = .primary
}
