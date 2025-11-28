//
//  VehicleDataManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/27/25.
//

import CoreData

class VehicleDataManager {
    static let shared = VehicleDataManager()
    private let context = PersistenceController.shared.context
    
    func addVehicle(vehicle: String,
        weight: Int64
    ) { let item = VehicleInfo(context: context)
        item.id = UUID()
        item.vehicle = vehicle
        item.weight = weight
        save()
    }
        
    
    func fetchAll() -> [VehicleInfo] {
        let request: NSFetchRequest<VehicleInfo> = VehicleInfo.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed \(error)")
            return []
        }
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func delete(item: VehicleInfo) {
        context.delete(item)
        save()
    }
}
