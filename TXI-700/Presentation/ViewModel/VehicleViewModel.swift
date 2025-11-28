//
//  VehicleViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class VehicleViewModel: ObservableObject {
    @Published var vehicleItems: [VehicleInfo] = []
    @Published var text: String = NSLocalizedString("VehicleScreenTitle", comment: "")
    @Published var vehicle: String = ""
    @Published var weight: String = ""
    @Published var items: [String] = []
    @Published var selectedRegion: String = ""
    
    private let vehicleManger = VehicleDataManager.shared
    
    init() {
        loadItems()
    }
    
    func fetchVehicleItems() {
        vehicleItems = vehicleManger.fetchAll()
    }
    
    func addVehicleItem() {
        let totalWeight = Int64(weight) ?? 0
        let vehicleName = selectedRegion+vehicle.replacingOccurrences(of: " ", with: "")
        
        vehicleManger.addVehicle(vehicle: vehicleName, weight: totalWeight)
        fetchVehicleItems()
        vehicle = ""
        weight = ""
    }
    
    func deleteVehicleItem(item: VehicleInfo) {
        vehicleManger.delete(item: item)
        fetchVehicleItems()
    }
    
    func loadItems() {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch lang {
            case "ja":
                items = ["ソウル", "京畿", "江原", "釜山", "大田", "大邱", "仁川", "光州", "蔚山", "忠北", "忠南", "全北", "全南", "慶北", "慶南", "済州"]
            case "ko":
                items = ["서울", "경기", "강원", "부산", "대전", "대구", "인천", "광주", "울산", "충북", "충남", "전북", "전남", "경북", "경남", "제주"]
            default:
                items = ["Seoul", "Gyeonggi", "Gangwon", "Busan", "Daejeon", "Daegu", "Incheon", "Gwangju", "Ulsan", "Chungbuk", "Chungnam", "Jeonbuk", "Jeonnam", "Gyeongbuk", "Gyeongnam", "Jeju"]
        }
    }
    
}
