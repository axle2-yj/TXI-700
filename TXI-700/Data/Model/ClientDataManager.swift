//
//  ClientDataManber.swift
//  TXI-700
//
//  Created by 서용준 on 11/27/25.
//

import CoreData

class ClientDataManber {
    static let shared = ClientDataManber()
    private let context = PersistenceController.shared.context
    
    func addProduct(
        id: UUID,
        name: String) {
            let item = ClientInfo(context: context)
            item.id = id
            item.name = name
            save()
        }
    
    func fetchAll() -> [ClientInfo] {
        let request: NSFetchRequest<ClientInfo> = ClientInfo.fetchRequest()
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
    
    func delete(item: ClientInfo) {
        context.delete(item)
        save()
    }
}
