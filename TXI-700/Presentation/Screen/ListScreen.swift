//
//  HomeScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct ListScreen: View {
    let listType: ListType
    
    @StateObject var productViewModel = ProductViewModel()
    @StateObject var cliantViewModel = CliantViewModel()
    @StateObject var vehicleViewModel = VehicleViewModel()
    
    var body: some View {
        VStack {
            switch listType {
            case .product:
                Text(productViewModel.text)
            case .cliant:
                Text(cliantViewModel.text)
            case .vehicle:
                Text(vehicleViewModel.text)
            }
        }.navigationTitle(titleText).padding()
    }
    
    private var titleText: String {
        switch listType {
        case .product:
            return "Product List"
        case .cliant:
            return "Clienat List"
        case .vehicle:
            return "Vehicle List"
        }
    }
}

#Preview {
    ListScreen(listType: .product)
}

