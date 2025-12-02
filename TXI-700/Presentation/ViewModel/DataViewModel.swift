//
//  DataViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine
import Foundation

enum DataResult {
    case success(message: String)
    case failure(error: DataError)
}

enum DataError: Error {
    case emptyData
    case indexOutOfRange
    case todayNoData
    case unknown
}

enum ActiveAlert: Identifiable {
    case success(String)
    case error(String)
    case deleteConfirm
    case printConfirm
    case sendConfirm
    var id: String {
        switch self {
        case .success: return "success"
        case .error: return "error"
        case .deleteConfirm: return "deleteConfirm"
        case .printConfirm: return "printConfirm"
        case .sendConfirm: return "sendConfirm"
        }
    }
}

class DataViewModel: ObservableObject {
    @Published var loadAxleItems: [LoadAxleInfo] = []
    @Published var title: String = NSLocalizedString("DataListScreenTitle", comment: "")
    @Published var dataDatilTitle: String = NSLocalizedString("DataDetailsScreenTitle", comment: "")
    
    // 실제 필터 입력용
    @Published var filterStartDate: Date?
    @Published var filterEndDate: Date?
    @Published var filterVehicle: String = ""
    @Published var filterClient: String = ""
    @Published var filterProduct: String = ""
    
    // 임시 입력용
    @Published var inputVehicle: String = ""
    @Published var inputClient: String = ""
    @Published var inputProduct: String = ""

    // Detail 화면 UI 설정
    @Published var showSections: [Bool?] = Array(repeating: true, count: 18)
    @Published var clientTitle: String? = nil
    @Published var productTitle: String? = nil
    
    @Published var selectedType: Int? = nil

    @Published var csvURL: URL? = nil
    private let dataManager = LoadAxleDataManager.shared
    
    init() {
        loadSettings()
        deleteAllCSVFilesInTempDirectory()
    }
    
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
        
    var todayLoadAxleItems: [LoadAxleInfo] {
        loadAxleItems.filter { item in
            guard let date = item.timestamp else { return false }
            return Calendar.current.isDateInToday(date)
        }
    }
    
    // MARK: - Fetch
    func fetchLoadAxleItems() {
        loadAxleItems = dataManager.fetchAll()
    }

    // MARK: - Add
    func addLoadAxle(serialNumber: String,
                     equipmentNumber: String,
                     client: String,
                     product: String,
                     vehicle: String,
                     loadAxleData: [Int] ) {
        dataManager.addLoadAxle(
            serialNumber: serialNumber,
            equipmentNumber: equipmentNumber,
            client: client,
            product: product,
            vehicle: vehicle,
            loadAxleStatus: loadAxleData
        )
        fetchLoadAxleItems()
    }

    // MARK: - 삭제 실행
    func selectedDeleteLoadAxle(at index: Int) -> Bool {
        guard loadAxleItems.indices.contains(index) else { return false }
        let item = loadAxleItems[index]
        dataManager.deleteItem(item)
        fetchLoadAxleItems()
        return true
    }

    func todayDeleteLoadAxle() -> Bool {
        let beforeCount = loadAxleItems.count
        dataManager.deleteToday()
        fetchLoadAxleItems()
        return loadAxleItems.count < beforeCount
    }

    func allDeleteLoadAxle() -> Bool {
        dataManager.deleteAll()
        fetchLoadAxleItems()
        return true
    }
    // MARK: - 공유 실행
    func selecetedSendLoadAxle(at index: Int) -> Bool {
        guard loadAxleItems.indices.contains(index) else { return false }
        let result = shareCSVFile(items: loadAxleItems, type: .selected(index))
        csvURL = result
        return true
    }
    
    func todaySendLoadAxle() -> Bool {
        guard !loadAxleItems.isEmpty else { return false }
        let result = shareCSVFile(items: loadAxleItems, type: .today)
        csvURL = result
        return ((result?.path.isEmpty) != nil)
    }
    
    func allSendLoadAxle() -> Bool {
        guard !loadAxleItems.isEmpty else { return false }
        let result = shareCSVFile(items: loadAxleItems, type: .all)
        csvURL = result
        return true
    }

    // MARK: - Filtered result
    var filteredItems: [LoadAxleInfo] {
        loadAxleItems.filter { item in
            let inDateRange: Bool = {
                guard let timestamp = item.timestamp else { return false }
                if let start = filterStartDate, let end = filterEndDate {
                    let startOfDay = Calendar.current.startOfDay(for: start)
                    let endOfDay = Calendar.current.date(
                        bySettingHour: 23, minute: 59, second: 59, of: end
                    ) ?? end
                    return timestamp >= startOfDay && timestamp <= endOfDay
                }
                return true
            }()
            
            let matchesVehicle = filterVehicle.isEmpty || (item.vehicle?.contains(filterVehicle) ?? false)
            let matchesClient = filterClient.isEmpty || (item.client?.contains(filterClient) ?? false)
            let matchesProduct = filterProduct.isEmpty || (item.product?.contains(filterProduct) ?? false)
            
            return inDateRange && matchesVehicle && matchesClient && matchesProduct
        }
    }

    func applyFilters(startDate: Date?, endDate: Date?) {
        filterStartDate = startDate
        filterEndDate = endDate
        filterVehicle = inputVehicle
        filterClient = inputClient
        filterProduct = inputProduct
    }

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
    
    // MARK: - Detail 화면 설정
    func loadSettings() {
        showSections = StorageManager.shared.loadToggles() ?? Array(repeating: true, count: 18)
        clientTitle = StorageManager.shared.loadClientTitle() ?? "Client <<"
        productTitle = StorageManager.shared.loadProductTitle() ?? "Item <<"
    }
    
    // 1 = 현재 선택, 2 = 오늘, 3 = 전체
    func toggleChanged(to newValue: Int) {
        if selectedType == newValue {
            selectedType = nil   // 같은 버튼 누르면 해제
        } else {
            selectedType = newValue
        }
    }
    
    func performDelete(
        selectedIndex: Int,
        loadAxleItem: inout LoadAxleInfo,
        currentIndex: inout Int
    ) -> DataResult {
        switch selectedType {
        case 1:
            if loadAxleItems.isEmpty {
                return .failure(error: .emptyData)
            }

            guard loadAxleItems.indices.contains(selectedIndex) else {
                return .failure(error: .indexOutOfRange)
            }

            if selectedDeleteLoadAxle(at: selectedIndex) {
                let result = adjustAfterSelectedDelete(
                    loadAxleItem: &loadAxleItem,
                    currentIndex: &currentIndex
                )
                if loadAxleItems.indices.contains(result) {
                    loadAxleItem = loadAxleItems[result]
                }
                return .success(message: NSLocalizedString("SuccessSelectedDelete", comment: ""))
            } else {
                return .failure(error: .unknown)
            }
        case 2:
            if todayLoadAxleItems.isEmpty {
                return .failure(error: .todayNoData)
            }

            if todayDeleteLoadAxle() {
                let result = adjustAfterTodayDelete(
                    loadAxleItem: &loadAxleItem,
                    currentIndex: &currentIndex
                )
                if loadAxleItems.indices.contains(result) {
                    loadAxleItem = loadAxleItems[result]
                }
                return .success(message: NSLocalizedString("SuccessTodayDelete", comment: ""))
            } else {
                return .failure(error: .unknown)
            }
        case 3:
            if allDeleteLoadAxle() {
                return .success(message: NSLocalizedString("SuccessAllDelete", comment: ""))
            } else {
                return .failure(error: .unknown)
            }

        default:
            return .failure(error: .unknown)
        }
    }
    
    func preformSend(
        selectedIndex: Int,
        loadAxleItem: inout LoadAxleInfo,
        currentIndex: inout Int
    ) -> DataResult {
        switch selectedType {
        case 1:
            if loadAxleItems.isEmpty {
                return .failure(error: .emptyData)
            }
            guard loadAxleItems.indices.contains(selectedIndex) else {
                return .failure(error: .indexOutOfRange)
            }
            if selecetedSendLoadAxle(at: selectedIndex) {
                return .success(message: NSLocalizedString("SuccessSelectedSend", comment: ""))
            } else {
                return .failure(error: .unknown)
            }
        case 2:
            if todayLoadAxleItems.isEmpty {
                print("11111111")
                return .failure(error: .todayNoData)
            }
            if todaySendLoadAxle() {
                return .success(message: NSLocalizedString("SuccessTodaySend", comment: ""))
            } else {
                print("22222222")
                return .failure(error: .unknown)
            }
        case 3:
            if allSendLoadAxle() {
                return .success(message: NSLocalizedString("SuccessAllSend", comment: ""))
            } else {
                return .failure(error: .unknown)
            }
        default:
            return .failure(error: .unknown)
        }
        
    }

    // MARK: - 삭제 후 처리
    private func adjustAfterSelectedDelete(
            loadAxleItem: inout LoadAxleInfo,
            currentIndex: inout Int
    ) -> Int {
        if currentIndex > 0 { currentIndex -= 1 }
        else { currentIndex = 0 }
        
        return currentIndex
    }
    
    private func adjustAfterTodayDelete(
            loadAxleItem: inout LoadAxleInfo,
            currentIndex: inout Int
    ) -> Int{
        currentIndex = 0
        
        return currentIndex
    }
    
    func shareCSVFile(items: [LoadAxleInfo], type: CSVDataType) -> URL? {
        // CSV 생성
        guard let csvURL = createCSVFile(items: items, type: type) else {
            print("CSV 생성 실패")
            return nil
        }

        return csvURL
    }
    
    func deleteErrorMessage(_ error: DataError) -> String {
        switch error {
        case .emptyData:
            return NSLocalizedString("EmptyDelteData", comment: "")
        case .indexOutOfRange:
            return NSLocalizedString("IndexOutOfRange", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        case .todayNoData:
            return NSLocalizedString("TodayNoDeleteData", comment: "")
        }
    }
    
    func printErrorMessage(_ error: DataError) -> String {
        switch error {
        case .emptyData:
            return NSLocalizedString("EmptyPrintData", comment: "")
        case .indexOutOfRange:
            return NSLocalizedString("IndexOutOfRange", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        case .todayNoData:
            return NSLocalizedString("TodayNoPrintData", comment: "")
        }
    }
    
    func sendErrorMessage(_ error: DataError) -> String {
        switch error {
        case .emptyData:
            return NSLocalizedString("EmptySendData", comment: "")
        case .indexOutOfRange:
            return NSLocalizedString("IndexOutOfRange", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "")
        case .todayNoData:
            return NSLocalizedString("TodayNoSendData", comment: "")
        }
    }
}
