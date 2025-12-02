//
//  SaveOrUpdateButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/22/25.
//

import SwiftUI
import Foundation

struct SaveOrUpdateButton: View {
    @State var text: String? = nil
    @EnvironmentObject var bleManager: BluetoothManager
    
    var onButton: () -> Void
    
    var body: some View {
        Button(text ?? "Save") {
            onButton()
        }
    }
}

