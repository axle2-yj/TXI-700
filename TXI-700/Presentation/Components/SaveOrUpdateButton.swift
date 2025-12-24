//
//  SaveOrUpdateButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/22/25.
//

import SwiftUI
import Foundation

struct SaveOrUpdateButton: View {
    let title: String
    
    var onButton: () -> Void
    
    var body: some View {
        Button(title) {
            onButton()
        }
    }
}

