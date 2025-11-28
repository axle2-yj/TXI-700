//
//  PrintButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI
import Foundation

struct PrintButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    
    let printDataByte: [UInt8] = [
        
    ]
    
    var body: some View {
        Button("PRINT") {
            
        }
        .padding()
    }
}
