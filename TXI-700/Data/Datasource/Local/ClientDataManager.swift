//
//  ClientDataManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/27/25.
//

import CoreData

class ClientDataManager {
    static let shared = ClientDataManager()
    private let context = PersistenceController.shared.context
    
    func addClient(name: String, num: Int16, shortcutNum: Int16) {
        let item = ClientInfo(context: context)
        item.id = UUID()
        item.name = name
        item.num = num
        item.shortcutNum = shortcutNum
        save()
    }
    
    func fetchAll() -> [ClientInfo] {
        let request: NSFetchRequest<ClientInfo> = ClientInfo.fetchRequest()
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
    
    func updateClient(
        item: ClientInfo,
        name: String,
        num: Int16,
        shortcutNum: Int16
    ) {
        item.name = name
        item.num = num
        item.shortcutNum = shortcutNum
        save()
    }
    
    
    func delete(item: ClientInfo) {
        context.delete(item)
        save()
    }
}
