//
//  ClockView.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Combine

struct ClockView: View {
    @Binding var currentTime: String
    
    var body: some View {
        Text(currentTime)
            .font(.system(size: 24, weight: .medium, design: .monospaced))
    }
}

