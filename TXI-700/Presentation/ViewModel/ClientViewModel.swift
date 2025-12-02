//
//  ClientViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class ClientViewModel: ObservableObject {
    @Published var clientItems: [ClientInfo] = []
    @Published var text: String = NSLocalizedString("ClientScreenTitle", comment: "")
    @Published var name: String = ""
    @Published var num: Int16 = 0
    @Published var selectedClient: ClientInfo? = nil

    private let clientManager = ClientDataManager.shared
    
    func fetchClientItems() {
        clientItems = clientManager.fetchAll()
    }
    
    func saveOrUpdateClient() {
        if let client = selectedClient {
                // UPDATE
                clientManager.updateClient(
                    item: client,
                    name: name,
                    num: client.num
                )
            } else {
                // ADD
                let nextNum = Int16(clientItems.count)
                clientManager.addClient(name: name, num: nextNum)
            }

            fetchClientItems()
            clearSelection()
    }
    
    func updateClient(item: ClientInfo, name: String, num: Int16) {
        clientManager.updateClient(item: item, name: name, num: num)
        fetchClientItems()
    }
    
    func deleteClient(item: ClientInfo) {
        clientManager.delete(item: item)
        fetchClientItems()
    }
    
    // MARK: - Reorder (롱클릭 이동)
    func moveClient(from source: IndexSet, to destination: Int) {
        clientItems.move(fromOffsets: source, toOffset: destination)
        reorderNum()
    }
    // MARK: - num 재정렬 공통 처리
    private func reorderNum() {
        for index in clientItems.indices {
            clientItems[index].num = Int16(index)
        }
        clientManager.save()
    }
    
    func selectClient(_ client: ClientInfo) {
        selectedClient = client
        name = client.name ?? ""
    }

    func clearSelection() {
        selectedClient = nil
        name = ""
    }
}
