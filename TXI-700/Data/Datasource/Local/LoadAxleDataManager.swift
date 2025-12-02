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
                     weightNum: String,
                     loadAxleStatus: [Int]) {
        let item = LoadAxleInfo(context: context)
        item.id = UUID()
        item.serialNumber = serialNumber
        item.equipmentNumber = equipmentNumber
        item.client = client
        item.product = product
        item.vehicle = vehicle
        item.timestamp = Date()
        item.weightNum = weightNum
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

    // 선택된 item 직접 삭제 (권장)
        func deleteItem(_ item: LoadAxleInfo) {
            context.delete(item)
            save()
        }

        // 오늘 데이터 전체 삭제
        func deleteToday() {
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start)!

            let request: NSFetchRequest<LoadAxleInfo> = LoadAxleInfo.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                                            start as NSDate, end as NSDate)

            if let items = try? context.fetch(request) {
                items.forEach { context.delete($0) }
                save()
            }
        }

        // 전체 삭제
        func deleteAll() {
            let items = fetchAll()
            items.forEach { context.delete($0) }
            save()
        }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

