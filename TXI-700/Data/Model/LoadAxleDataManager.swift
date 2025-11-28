//
//  LoadAxleDataManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/26/25.
//

import CoreData

class LoadAxleDataManager {
    static let shared = LoadAxleDataManager()
    private let context = PersistenceController.shared.context

    func addLoadAxle(client: String,
                     product: String,
                     vehicle: String,
                     loadAxleStatus: [Int]) {
        let item = LoadAxleInfo(context: context)
        item.id = UUID()
        item.client = client
        item.product = product
        item.vehicle = vehicle
        item.timestamp = Date()
        if let data = try? JSONEncoder().encode(loadAxleStatus) {
                    item.loadAxleData = data
                }
        
        save()
    }

    func fetchAll() -> [LoadAxleInfo] {
        let request: NSFetchRequest<LoadAxleInfo> = LoadAxleInfo.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    func delete(item: LoadAxleInfo) {
        context.delete(item)
        save()
    }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

