//
//  CliantViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class ClientViewModel: ObservableObject {
    @Published var clientItems: [ClientInfo] = []
    @Published var text: String = NSLocalizedString("CliantScreenTitle", comment: "")
    @Published var name: String = ""
    
    private let clientManger = ClientDataManager.shared
    
    func fetchClientItems() {
        clientItems = clientManger.fetchAll()
    }
    
    func addClient() {
        clientManger.addClient(name: name)
        fetchClientItems()
        name = ""
    }
    
    func deleteClient(item: ClientInfo) {
        clientManger.delete(item: item)
        fetchClientItems()
    }
}
