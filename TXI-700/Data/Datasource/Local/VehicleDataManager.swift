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
    
    func addVehicle(
        vehicle: String,
        weight: Int64,
        num: Int16
    ) { let item = VehicleInfo(context: context)
        item.id = UUID()
        item.vehicle = vehicle
        item.weight = weight
        item.num = num
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
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func updateVehicle(
        item: VehicleInfo,
        vehicle: String,
        weight: Int64,
        num: Int16
    ) {
        item.vehicle = vehicle
        item.weight = weight
        item.num = num
        save()
    }
    
    
    func delete(item: VehicleInfo) {
        context.delete(item)
        save()
    }
}
