//
//  LoadAxleSaveService.swift
//  TXI-700
//
//  Created by 서용준 on 12/16/25.
//

struct LoadAxleSaveService: Equatable {
    static func printSaveData(
            serialNumber: String,
            equipmentNumber: String,
            client: String,
            product: String,
            vehicle: String,
            weightNum: String,
            loadAxleStatus: [LoadAxleStatus],
            completion: (() -> Void)? = nil
    ) {
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
            print("✅ All data saved")
        }
        completion?()
    }
}
