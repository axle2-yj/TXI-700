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
    @EnvironmentObject var languageManager: LanguageManager
    
    // MARK: - Width
    // print form Max 30
    //
    static let fullWidth = 30
    static let width4 = 4
    static let width5 = 5
    static let width6 = 6
    static let width7 = 7
    static let width8 = 8
    static let width9 = 9
    static let width10 = 10
    static let width11 = 11
    static let width16 = 16
    static let width17 = 17
    static let width14 = 14
    static let width20 = 20
    static let width22 = 22
    
    // MARK: - Rows
    
    static func fullRow(_ text: String) -> String {
        text.leftAlignedPrint(width: fullWidth)
    }
    
    static func twoColBasicRow(_ left: String, _ right: String) -> String {
        let l = left.leftAlignedPrint(width: width8)
        let r = right.leftAlignedPrint(width: width22)
        return "\(l)\(r)"
    }
    
    static func twoColAlignedRow(
        _ col1: String,
        _ col2: String,
        _ percent: Double
    ) -> String {
        
        let l = col1.fitToPrintWidth(width11)
        let m1 = ":".fitToPrintWidth(width4)
        let m2 = col2.rightAlignedPrint(width: width7)
        
        let rText = percent.percentTextOrEmpty()
        let r = rText.rightAlignedPrint(width: width7)
        
        return l+m1+m2+r
    }
    
    static func twoColRow(_ left: String, _ right: String) -> String {
        let l = left.padding(toLength: width8, withPad: " ", startingAt: 0)
        let r = right.rightAligned(width: width22)
        return "\(l)\(r)"
    }
    
    static func twoColRowLeftAligned(_ text: String, _ middle: String) -> String {
        let l = text.leftAlignedPrint(width: width10)
        let r = middle.centerAligned(width: width6)
        return "\(l)\(r)"
    }
    
    static func oneColRowRightAligend(_ text: String) -> String {
        text.rightAlignedPrint(width: width14)
    }
    
    static func twoColRowLeftInspector(_ text: String, _ middle: String) -> String {
        let l = text.leftAlignedPrint(width: width9)
        let r = middle.centerAligned(width: width6)
        return "\(l)\(r)"
    }
    
    static func oneColRowEnd(_ text: String) -> String {
        text.rightAlignedPrint(width: fullWidth + 1)
    }
    
    static func oneColRowEndInspector(_ text: String) -> String {
        text.rightAlignedPrint(width: fullWidth)
    }
    
    static func threeColRowLift(_ col1: String, _ col2: String, _ col3: String) -> String {
        let one = col1.leftAlignedPrint(width: width9)
        let two = col2.centerAligned(width: width6)
        let three = col3.leftAlignedPrint(width: width14)
        return "\((one))\(two)\(three)"
    }
    
    static func fiveColRow(_ col1: String, _ col2: String, _ col3: String, _ col4: String, _ col5: String) -> String {
        let one = col1.leftAlignedPrint(width: width5)
        let two = col2.centerAligned(width: width6)
        let three = col3.rightAligned(width: width7)
        let four = col4.centerAligned(width: width6)
        let five = col5.rightAligned(width: width7)
        return "\((one))\(two)\(three)\(four)\(five)"
    }
    
//    static func threeColumnLine(_ col1: String, _ col2: String, _ col3: String) -> String {
//        return
//        col1.fitToPrintWidth(9) +
//        col2.fitToPrintWidth(3) +
//        col3.fitToPrintWidth(18)
//    }
    
    static func oneColRowRight(_ text: String) -> String {
        text.rightAlignedPrint(width: fullWidth + 1)
    }
}

extension String {
    
    func leftAlignedPrint(width: Int) -> String {
        var result = ""
        var currentWidth = 0
        
        for scalar in unicodeScalars {
            let w = scalar.isASCII ? 1 : 2
            if currentWidth + w > width { break }
            result.unicodeScalars.append(scalar)
            currentWidth += w
        }
        
        if currentWidth < width {
            result += String(repeating: " ", count: width - currentWidth)
        }
        
        return result
    }
    
    func rightAlignedPrint(width: Int) -> String {
        let currentWidth = self.printWidth
        guard currentWidth < width else { return self }
        return String(repeating: " ", count: width - count) + self
    }
    
    func rightAligned(width: Int) -> String {
        let currentWidth = self.printWidth
        if currentWidth >= width { return self }
        return String(repeating: " ", count: width - count) + self
    }
    
    func centerAligned(width: Int) -> String {
        let currentWidth = self.printWidth
        guard currentWidth < width else { return self }
        
        let totalPadding = width - currentWidth
        let leftPadding = totalPadding / 2
        let rightPadding = totalPadding - leftPadding
        
        return String(repeating: " ", count: leftPadding)
        + self
        + String(repeating: " ", count: rightPadding)
    }
    
    func fitToWidth(_ width: Int) -> String {
        var result = ""
        var currentWidth = 0
        
        for scalar in unicodeScalars {
            let w = scalar.isASCII ? 1 : 2
            if currentWidth + w > width { break }
            result.unicodeScalars.append(scalar)
            currentWidth += w
        }
        
        if currentWidth < width {
            result += String(repeating: " ", count: width - currentWidth)
        }
        
        return result
    }
    
    //    var printWidth: Int {
    //        unicodeScalars.reduce(0) { width, scalar in
    //            width + (scalar.isASCII ? 1 : 2)
    //        }
    //    }
    
    var printWidth: Int {
        self.reduce(0) { width, char in
            // CJK 범위 → 폭 2
            if char.unicodeScalars.contains(where: {
                $0.value >= 0x1100 &&
                ($0.value <= 0x115F ||
                 $0.value == 0x2329 ||
                 $0.value == 0x232A ||
                 ($0.value >= 0x2E80 && $0.value <= 0xA4CF) ||
                 ($0.value >= 0xAC00 && $0.value <= 0xD7A3) ||
                 ($0.value >= 0xF900 && $0.value <= 0xFAFF) ||
                 ($0.value >= 0xFE10 && $0.value <= 0xFE19) ||
                 ($0.value >= 0xFE30 && $0.value <= 0xFE6F) ||
                 ($0.value >= 0xFF00 && $0.value <= 0xFF60) ||
                 ($0.value >= 0xFFE0 && $0.value <= 0xFFE6))
            }) {
                return width + 2
            } else {
                return width + 1
            }
        }
    }
    
    func fitToPrintWidth(_ width: Int) -> String {
        var result = ""
        var currentWidth = 0
        
        for char in self {
            let charWidth = String(char).printWidth
            if currentWidth + charWidth > width { break }
            result.append(char)
            currentWidth += charWidth
        }
        
        if currentWidth < width {
            result += String(repeating: " ", count: width - currentWidth)
        }
        
        return result
    }
}

extension Double {
    func percentTextOrEmpty() -> String {
        if self == 0.0 {
            return ""
        }
        return String(format: "(%05.2f%%)", self)
    }
    
    func fixed(_ digits: Int = 2) -> String {
        String(format: "%.\(digits)f", self)
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

struct PrintPreviewLine: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .frame(width: 70, alignment: .leading)
            Text(":")
                .frame(width: 30, alignment: .center)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

struct PrintTwoStepPreviewLine: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .frame(width: 90, alignment: .leading)
            Text(":")
                .frame(width: 30, alignment: .center)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

struct PrintPreviewThreeLine: View {
    let title: String
    let value1: String
    let value2: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .frame(width: 70, alignment: .leading)
            Text(":")
                .frame(width: 10, alignment: .center)
            Text(value1)
                .frame(width: 90, alignment: .trailing)
            Text("/")
                .frame(width: 10, alignment: .center)
            Text(value2)
                .frame(width: 90, alignment: .trailing)
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

struct PrintBalanceLine: View {
    let title: String
    let value1: String
    let value2: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .frame(width: 70, alignment: .leading)
            Text(":")
                .frame(width: 30, alignment: .center)
            Text(value1)
                .frame(width: 90, alignment: .trailing)
            Text(value2)
                .frame(width: 90, alignment: .leading)
        }
        .font(.system(size: 14, design: .monospaced))
    }
}
