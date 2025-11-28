//
//  SaveButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI
import Foundation

struct SaveButton: View {
    @Binding var loadAxleStatus: [LoadAxleStatus]
    var client: String
    var product: String
    var vehicle: String
    
    var body: some View {
        Button("SAVE") {
            saveData()
        }
        .padding()
    }
    
    private func saveData() {
        for status in loadAxleStatus {
            LoadAxleDataManager.shared.addLoadAxle(
                client: client,
                product: product,
                vehicle: vehicle,
                loadAxleStatus: status.loadAxlesData
            )
        }
        print("✅ All data saved")
    }
}
