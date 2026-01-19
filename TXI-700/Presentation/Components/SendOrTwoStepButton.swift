//
//  SendOrTwoStepButton.swift
//  TXI-700
//
//  Created by 서용준 on 1/15/26.
//

import SwiftUI

public struct SendOrTwoStepButton: View {
    let title: String
    let action: () -> Void
    let isDisabled: Bool
    let tint: Color
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title).padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                .foregroundColor(tint)
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.4 : 1.0)
                .contentShape(Rectangle())
        }
    }
}
