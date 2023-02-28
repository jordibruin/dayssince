//
//  View+Extensions.swift
//  DaysSince
//
//  Created by Vicki Minerva on 2/28/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DismissKeyboard: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DismissKeyboard>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DismissKeyboard>) {
        uiViewController.view.endEditing(true)
    }
    
}
