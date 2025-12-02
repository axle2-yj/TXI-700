//
//  DataViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine
import Foundation

class DataViewModel: ObservableObject {
    @Published var loadAxleItems: [LoadAxleInfo] = []
    @Published var title: String = NSLocalizedString("DataListScreenTitle", comment: "")
    @Published var dataDatilTitle: String = NSLocalizedString("DataDetailsScreenTitle", comment: "")
    
    // 실제 필터 적용용
    @Published var filterStartDate: Date?
    @Published var filterEndDate: Date?
    @Published var filterVehicle: String = ""
    @Published var filterClient: String = ""
    @Published var filterProduct: String = ""
    
    // 임시 입력용 (Search 버튼 클릭 전)
    @Published var inputVehicle: String = ""
    @Published var inputClient: String = ""
    @Published var inputProduct: String = ""
    
    // Data Detail 출력
    @Published var showSections: [Bool?] = Array(repeating: true, count: 18)
    
    @Published var clientTitle: String? = nil
    @Published var productTitle: String? = nil
    init() {
            loadSettings()
        }
    
    private let dataManager = LoadAxleDataManager.shared
    // Timestamp Formatter
    let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()
    
    // 날짜만 보여주는 Formatter
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"   // 시:분:초
        return formatter
    }()
    
    func fetchLoadAxleItems() {
        loadAxleItems = dataManager.fetchAll() // [LoadAxleInfo] 타입
    }

    func addLoadAxle(serialNumber: String,
                     equipmentNumber: String,
                     client: String,
                     product: String,
                     vehicle: String,
                     loadAxleData: [Int] ) {
        dataManager.addLoadAxle(serialNumber: serialNumber,
                                equipmentNumber: equipmentNumber,
                                client: client,
                                product: product,
                                vehicle: vehicle,
                                loadAxleStatus: loadAxleData)
        fetchLoadAxleItems()
    }

    func allDeleteLoadAxle(item: LoadAxleInfo) {
        dataManager.allDelete(item: item)
        fetchLoadAxleItems()
    }
    
    func selectedDeleteLoadAxle(item: LoadAxleInfo) {
        dataManager.selectedDelete(at: loadAxleItems.firstIndex(of: item)!)
        fetchLoadAxleItems()
    }
    
    func todayDeleteLoadAxle() {
        LoadAxleDataManager.shared.todayDelete()
        fetchLoadAxleItems()
    }
    
    // 필터링된 데이터 반환
    var filteredItems: [LoadAxleInfo] {
        loadAxleItems.filter { item in
            // 날짜 필터
            let inDateRange: Bool = {
                guard let timestamp = item.timestamp else { return false }
                if let start = filterStartDate, let end = filterEndDate {
                    let startOfDay = Calendar.current.startOfDay(for: start)
                    let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
                    return (timestamp >= startOfDay && timestamp <= endOfDay)
                }
                return true
            }()
            
            // 차량번호/고객/품목 필터
            let matchesVehicle = filterVehicle.isEmpty || (item.vehicle?.contains(filterVehicle) ?? false)
            let matchesClient = filterClient.isEmpty || (item.client?.contains(filterClient) ?? false)
            let matchesProduct = filterProduct.isEmpty || (item.product?.contains(filterProduct) ?? false)
            
            return inDateRange && matchesVehicle && matchesClient && matchesProduct
        }
    }
    
    // Search 버튼 클릭 시 호출
        func applyFilters(startDate: Date?, endDate: Date?) {
            self.filterStartDate = startDate
            self.filterEndDate = endDate
            self.filterVehicle = inputVehicle
            self.filterClient = inputClient
            self.filterProduct = inputProduct
        }

        // Clear 버튼 클릭 시 호출
        func clearFilters() {
            filterStartDate = nil
            filterEndDate = nil
            filterVehicle = ""
            filterClient = ""
            filterProduct = ""

            inputVehicle = ""
            inputClient = ""
            inputProduct = ""
        }
    
    // Data Detail 화면 설정
    func loadSettings() {
        showSections = StorageManager.shared.loadToggles() ?? []
        clientTitle = StorageManager.shared.loadClientTitle() ?? "Client"
        productTitle = StorageManager.shared.loadProductTitle() ?? "Item"
    }
}
