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
    var serialNumber: String
    var equipmentNumber: String
    
    @State private var isSaved: Bool = false
    
    var body: some View {
        Button("SAVE") {
            saveData()
            isSaved = true
        }.frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(6)
        .foregroundColor(.black)
        .disabled(isSaved)
        .opacity(isSaved ? 0.4 : 1.0)
    }
    
    private func saveData() {
        for status in loadAxleStatus {
            LoadAxleDataManager.shared.addLoadAxle(
                serialNumber: serialNumber,
                equipmentNumber: equipmentNumber,
                client: client,
                product: product,
                vehicle: vehicle,
                loadAxleStatus: status.loadAxlesData
            )
        }
        print("✅ All data saved")
    }
}
