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
    @Published var searchText: String = ""
    let lang = Locale.current.language.languageCode?.identifier ?? "en"

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
    
    func loadRegions() -> [String] {
            if let url = Bundle.main.url(forResource: language(), withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let regions = try? JSONDecoder().decode([String].self, from: data) {
                return regions
            }
            return []
        }
    
    func language() -> String {
        switch lang {
            case "ja":
                "jepenRegions"
            case "ko":
                "koreaRegions"
            default:
                "regions"
        }
    }
    
    func loadItems() {
        items = loadRegions()
    }
    
}
