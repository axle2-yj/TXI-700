//
//  ProductDataManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/27/25.
//

import CoreData

class ProductDataManager {
    static let shared = ProductDataManager()
    private let context = PersistenceController.shared.context
    
    func addProduct(name: String, num: Int16, shortcutNum: Int16) {
        let item = ProductInfo(context: context)
        item.id = UUID()
        item.name = name
        item.num = num
        item.shortcutNum = shortcutNum
        save()
    }
    
    func fetchAll() -> [ProductInfo] {
        let request: NSFetchRequest<ProductInfo> = ProductInfo.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "num", ascending: true)
        ]
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
    
    func updateProduct(
        item: ProductInfo,
        name: String,
        num: Int16,
        shortcutNum: Int16
    ) {
        item.name = name
        item.num = num
        item.shortcutNum = shortcutNum
        save()
    }
    
    func delete(item: ProductInfo) {
        context.delete(item)
        save()
    }
}
