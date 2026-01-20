//
//  SaveButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI
import Foundation

struct SaveButton: View {
    let beforeSave: (() -> Void)?
    @Binding var loadAxleStatus: [LoadAxleStatus]
    var client: String
    var product: String
    var vehicle: String
    var serialNumber: String
    var equipmentNumber: String
    var weightNum: String
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isSaved: Bool = false
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        Button {
            beforeSave?()
            saveData()
            isSaved = true
        } label: {
            Text("SAVE")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                .foregroundColor(tint)
                .disabled(isSaved)
                .opacity(isSaved ? 0.4 : 1.0)
                .contentShape(Rectangle())
        }
    }
    
    private func saveData() {
        for status in loadAxleStatus {
            LoadAxleDataManager.shared.addLoadAxle(
                serialNumber: serialNumber,
                equipmentNumber: equipmentNumber,
                client: client,
                product: product,
                vehicle: vehicle,
                weightNum: weightNum,
                loadAxleStatus: status.loadAxlesData
            )
        }
        print(loadAxleStatus)
        print("✅ All data saved")
    }
}
