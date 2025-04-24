//
//  Helpers.swift
//  MyWorkoutApp
//
//  Created by David Santos on 4/23/25.
//


import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
