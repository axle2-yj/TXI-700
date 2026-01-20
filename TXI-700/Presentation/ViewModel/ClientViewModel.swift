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
    @Published var selectedClient: ClientInfo? = nil
    @Published var saveSuccessMessage: String? = nil
    @Published var saveFailedMessage: String? = nil
    
    @EnvironmentObject var languageManager: LanguageManager
    
    private let clientManager = ClientDataManager.shared
    
    func fetchClientItems() {
        clientItems = clientManager.fetchAll()
    }
    
    func saveOrUpdateClient() {
        guard !name.isEmpty else {
            saveFailedMessage = "pleaseEnterClientName"
            return
        }
        
        // 중복 체크
        if clientItems.contains(where: { $0.name == name && $0.id != selectedClient?.id}) {
            saveFailedMessage = "registeredClientName"
            return
        }
        
        if let client = selectedClient {
            // UPDATE
            clientManager.updateClient(
                item: client,
                name: name.replacingOccurrences(of: " ", with: ""),
                num: client.num,
                shortcutNum: client.shortcutNum
            )
        } else {
            // ADD
            let nextNum = Int16(clientItems.count)
            let netxShortcutNum = Int16(clientItems.count)
            clientManager.addClient(name: name.replacingOccurrences(of: " ", with: ""), num: nextNum, shortcutNum: netxShortcutNum)
        }
        
        fetchClientItems()
        clearSelection()
        saveSuccessMessage = "saved"
    }
    
    func updateClient(item: ClientInfo, name: String, num: Int16, shortcutNum: Int16) {
        clientManager.updateClient(item: item, name: name, num: num, shortcutNum: shortcutNum)
        fetchClientItems()
    }
    
    func deleteClient(item: ClientInfo) {
        clientManager.delete(item: item)
        fetchClientItems()
        reorderNum()
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
