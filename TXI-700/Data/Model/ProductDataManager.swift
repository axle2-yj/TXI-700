//
//  ProductDataManber.swift
//  TXI-700
//
//  Created by 서용준 on 11/27/25.
//

import CoreData

class ProductDataManager {
    static let shared = ProductDataManager()
    private let context = PersistenceController.shared.context
    
    func addProduct(
        id: UUID,
        name: String) {
            let item = ProductInfo(context: context)
            item.id = id
            item.name = name
            save()
        }
    
    func fetchAll() -> [ProductInfo] {
        let request: NSFetchRequest<ProductInfo> = ProductInfo.fetchRequest()
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
    
    func delete(item: ProductInfo) {
        context.delete(item)
        save()
    }
}
