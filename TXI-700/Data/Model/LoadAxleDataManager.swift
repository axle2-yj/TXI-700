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

    func addLoadAxle(serialNumber: String,
                     equipmentNumber: String,
                     client: String,
                     product: String,
                     vehicle: String,
                     loadAxleStatus: [Int]) {
        let item = LoadAxleInfo(context: context)
        item.id = UUID()
        item.serialNumber = serialNumber
        item.equipmentNumber = equipmentNumber
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

    func allDelete(item: LoadAxleInfo) {
        context.delete(item)
        save()
    }
    
    func selectedDelete(at index: Int) {
        let items = fetchAll()
        guard index >= 0 && index < items.count else { return }
        let item = items[index]
        context.delete(item)
        save()
    }
    
    func todayDelete() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date()) // 오늘 0시
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1) // 오늘 23:59:59

        let request: NSFetchRequest<LoadAxleInfo> = LoadAxleInfo.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@",
                                        startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let items = try context.fetch(request)
            items.forEach { context.delete($0) }
            save()
            print("Deleted all items for today")
        } catch {
            print("Failed to delete today's items: \(error)")
        }
    }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

