//
//  CommonView.swift
//  TXI-700
//
//  Created by 서용준 on 1/7/26.
//

import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    func onKeyboardDismiss(_ action: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillHideNotification
            )
        ) { _ in
            action()
        }
    }
}
struct CommonPrintFormatter {
    
    // MARK: - Width
    static let fullWidth = 30
    static let Col1Width = 8
    static let Col2Width = 14
    static let Col3Width = 8
    static let Col4Width = 22
    
    // MARK: - Rows
    
    static func fullRow(_ text: String) -> String {
        text.leftAlignedPrint(width: fullWidth)
    }
    
    static func twoColBasicRow(_ left: String, _ right: String) -> String {
        let l = left.leftAlignedPrint(width: Col1Width)
        let r = right.leftAlignedPrint(width: Col4Width)
        return "\(l)\(r)"
    }
    
    static func twoColAlignedRow(
        _ col1: String,
        _ col2: String,
        _ percent: Double
    ) -> String {
        
        let l = col1.leftAlignedPrint(width: Col1Width)
        let m = col2.rightAlignedPrint(width: Col2Width)
        
        let rText = percent.percentTextOrEmpty()
        let r = rText.rightAlignedPrint(width: Col3Width)
        
        return "\(l)\(m)\(r)"
    }
    
    static func twoColRow(_ left: String, _ right: String) -> String {
        let l = left.padding(toLength: Col1Width, withPad: " ", startingAt: 0)
        let r = right.rightAligned(width: Col4Width)
        return "\(l)\(r)"
    }
}

extension String {
    
    func leftAlignedPrint(width: Int) -> String {
        if count >= width { return String(prefix(width)) }
        return self + String(repeating: " ", count: width - count)
    }
    
    func rightAlignedPrint(width: Int) -> String {
        if count >= width { return String(suffix(width)) }
        return String(repeating: " ", count: width - count) + self
    }
}

extension String {
    func rightAligned(width: Int) -> String {
        if count >= width { return self }
        return String(repeating: " ", count: width - count) + self
    }
}

extension Double {
    func percentTextOrEmpty() -> String {
        if self == 0.0 {
            return ""
        }
        return String(format: "(%05.2f%%)", self)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: &$keyboardHeight)
    }
}
