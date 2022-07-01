////
////  Counter.swift
////  Supporter
////
////  Created by Jordi Bruin on 05/12/2021.
////
//
//import Foundation
//
//
///// This handles the private analytics. When a user triggers an event, a +1 is added to a counter. You can replace this with your own analytics if you want.
//struct Analytics {
//    static func hit(_ option: CounterOption) {
//        var analyticsPostfix = ""
//        if isSimulatorOrTestFlight() {
//            analyticsPostfix = "tf"
//        }
//        
//        // Turned off by default
//        guard let url = URL(string: "https://api.countapi.xyz/hit/com.goodsnooze.posturepal/\(option.stringValue())\(analyticsPostfix)") else { return }
//        let request = URLRequest(url: url)
//        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
//        print("📊 \(option.stringValue()) ")
//    }
//}
//
//enum CounterOption: Hashable {
//      
//    case support
//    case openedSupport(Int)
//    case openedWrong(Int)
//
//    case setSensitivity(PostureSensitivity)
//    case openTheme
//    case chooseIcon(String)
//    
//    case choosePattern(Pattern)
//    
//    case proTheme
//    case proSensitivity
//    case proIcons
//    case proDuration
//    case proSettings
//    case proOnboarding
//    case proTrackOnLaunch
//    case proAlertDelay
//    case proSoundFrequency
//
//    case proScreenOpened
//    case proStartPurchase
//    case proPurchased
//    
//    case startShare
//    case settingsReview
//    case reviewPrompt
//    
//    case seriousModeOn
//    
//    func stringValue() -> String {
//        switch self {
//        case .support:
//            return "support"
//        case .openedSupport(let id):
//            return "openedSupportId\(id)"
//        case .openedWrong(let id):
//            return "openedWrong\(id)"
//        case .chooseIcon(let id):
//            return "chooseIcon\(id)"
//        case .setSensitivity(let sensitivity):
//            return "setSensitivity\(sensitivity.angle)"
//        case .choosePattern(let pattern):
//            return "choosePattern\(pattern.id)"
//        case .openTheme:
//            return "openTheme"
//        case .proTheme:
//            return "proTheme"
//        case .proSensitivity:
//            return "proSensitivity"
//        case .proIcons:
//            return "proIcons"
//        case .proDuration:
//            return "proDuration"
//        case .proSettings:
//            return "proSettings"
//        case .settingsReview:
//            return "settingsReview"
//        case .proStartPurchase:
//            return "proStartPurchase"
//        case .proPurchased:
//            return "proPurchased"
//        case .proOnboarding:
//            return "proOnboarding"
//        case .proTrackOnLaunch:
//            return "proTrackOnLaunch"
//        case .proAlertDelay:
//            return "proAlertDelay"
//        case .proSoundFrequency:
//            return "proSoundFrequency"
//        case .reviewPrompt:
//            return "reviewPrompt"
//        case  .proScreenOpened:
//            return "proScreenOpened"
//        case .startShare:
//            return "startShare"
//        case .seriousModeOn:
//            return "seriousModeOn"
//        }
//    }
//}
//
//public func isSimulatorOrTestFlight() -> Bool {
//    guard let path = Bundle.main.appStoreReceiptURL?.path else {
//        return false
//    }
//    return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
//}
