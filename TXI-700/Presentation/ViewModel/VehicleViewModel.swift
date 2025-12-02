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
    @Published var num: Int16 = 0
    @Published var items: [String] = []
    @Published var selectedRegion: String = ""
    @Published var searchText: String = ""
    @Published var selectedVehicle: VehicleInfo? = nil
    var lang = Locale.current.language.languageCode?.identifier ?? "en"

    private let vehicleManger = VehicleDataManager.shared

    init() {
        loadItems()
    }
    
    func fetchVehicleItems() {
        vehicleItems = vehicleManger.fetchAll()
    }
    
    func saveOrUpdateVehicleItem() {
        print(selectedRegion+vehicle.replacingOccurrences(of: " ", with: ""))
        if let vehicleinfo = selectedVehicle {
            vehicleManger.updateVehicle(
                // UPDATE
                item: vehicleinfo,
                vehicle: selectedRegion+vehicle.replacingOccurrences(of: " ", with: ""),
                weight: Int64(weight) ?? 0,
                num: vehicleinfo.num)
        } else {
            // ADD
            let nextNum = Int16(vehicleItems.count)
            vehicleManger.addVehicle(vehicle: selectedRegion+vehicle.replacingOccurrences(of: " ", with: ""), weight: Int64(weight) ?? 0, num: nextNum)
        }
        fetchVehicleItems()
        clearSelection()
    }
    
    func deleteVehicleItem(item: VehicleInfo) {
        vehicleManger.delete(item: item)
        fetchVehicleItems()
    }
    
    func moveVechile(from source: IndexSet, to destination: Int) {
        vehicleItems.move(fromOffsets: source, toOffset: destination)
        reorderNum()
    }
    
    private func reorderNum() {
        for index in vehicleItems.indices {
            vehicleItems[index].num = Int16(index)
        }
        vehicleManger.save()
    }
    
    func selectVehicle(_ vehicleInfo: VehicleInfo) {
        self.selectedVehicle = vehicleInfo
        self.vehicle = String(vehicleInfo.vehicle ?? "")
        self.weight = String(vehicleInfo.weight)
    }
    
    func clearSelection() {
        selectedVehicle = nil
        vehicle = ""
        weight = ""
        selectedRegion = ""
    }
    
    func loadRegions() -> [String] {
            if let url = Bundle.main.url(forResource: language(), withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let regions = try? JSONDecoder().decode([String].self, from: data) {                return regions
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
    
    func updateLanguage(_ lang: String) {
        self.lang = lang
        self.items = loadRegions()
    }
}
