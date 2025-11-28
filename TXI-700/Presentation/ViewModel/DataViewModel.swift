//
//  DataViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine
import Foundation
import SwiftUI

class DataViewModel: ObservableObject {
    @Published var loadAxleItems: [LoadAxleInfo] = []
    @Published var text: String = NSLocalizedString("DataListScreenTitle", comment: "")
    
    private let dataManager = LoadAxleDataManager.shared

    func fetchLoadAxleItems() {
        loadAxleItems = dataManager.fetchAll() // [LoadAxleInfo] 타입
    }

    func addLoadAxle(client: String,
                     product: String,
                     vehicle: String,
                     loadAxleData: [Int] ) {
        dataManager.addLoadAxle(client: client,
                                product: product,
                                vehicle: vehicle,
                                loadAxleStatus: loadAxleData)
        fetchLoadAxleItems()
    }

    func deleteLoadAxle(item: LoadAxleInfo) {
        dataManager.delete(item: item)
        fetchLoadAxleItems()
    }
}
