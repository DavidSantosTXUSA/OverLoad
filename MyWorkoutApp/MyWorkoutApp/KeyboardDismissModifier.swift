import SwiftUI
import UIKit

// Helper for dismissing the keyboard from anywhere
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

// ViewModifier that adds tap-to-dismiss behavior
struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle()) // allows tapping anywhere
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

// View extension for easy access
extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
