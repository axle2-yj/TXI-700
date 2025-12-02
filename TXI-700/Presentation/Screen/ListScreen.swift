//
//  ListScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct ListScreen: View {
    let listType: ListType
    @State private var isAddMode = false
    @State private var selectedListType: ListType? = nil

    @ObservedObject var productViewModel: ProductViewModel
    @ObservedObject var clientViewModel: ClientViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    
    @Environment(\.presentationMode) var presentationMode

    var onSelectProduct: ((ProductInfo) ->Void)?
    var onSelectClient: ((ClientInfo) -> Void)?
    var onSelectVehicle: ((VehicleInfo) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            CustomListTopBar(title: titleText,onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onChange: {
                newMode in
                        isAddMode = !newMode
                        print("현재 모드:", newMode ? "X" : "Add")
            })

            if isAddMode {
                HStack {
                    switch listType {
                    case .product:
                        TextField("product", text: $productViewModel.name)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            productViewModel.addProdut()
                        }
                    case .client:
                        TextField("client", text: $clientViewModel.name)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            clientViewModel.addClient()
                        }
                    case .vehicle:
                        VehicleRegionDropdown(viewModel: vehicleViewModel).onAppear {
                            vehicleViewModel.loadItems()
                        }
                    }
                }.padding(5)
            }
            
            VStack {
                
                    switch listType {
                    case .product:
                        if productViewModel.productItems.isEmpty {
                            Spacer()
                            Text("No Data")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        else {
                            List {
                                ForEach(productViewModel.productItems) { item in
                                    HStack {
                                        Text("\(item.name ?? "")")
                                        Spacer()
                                        if isAddMode {
                                            Button(action: { productViewModel.deleteProduct(item: item) }) {
                                                Image(systemName: "trash")
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(8)
                                    .contentShape(Rectangle()) // HStack 전체 영역을 클릭 가능하게 함
                                    .onTapGesture {
                                        if !isAddMode {
                                            onSelectProduct?(item)
                                        }
                                    }
                                }
                            }
                        }
                        
                    case .client:
                        if clientViewModel.clientItems.isEmpty {
                            Spacer()
                            Text("No Data")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        else {
                            List {
                                ForEach(clientViewModel.clientItems) { item in
                                    HStack {
                                        Text("\(item.name ?? "")")
                                        Spacer()
                                        if isAddMode {
                                            Button(action: { clientViewModel.deleteClient(item: item) }) {
                                                Image(systemName: "trash")
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(8)
                                    .contentShape(Rectangle()) // HStack 전체 영역을 클릭 가능하게 함
                                    .onTapGesture {
                                        if !isAddMode {
                                            onSelectClient?(item)
                                        }
                                    }
                                }
                            }
                        }
                    case .vehicle:
                        if vehicleViewModel.vehicleItems.isEmpty {
                            Spacer()
                            Text("No Data")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        else {
                            List {
                                ForEach(vehicleViewModel.vehicleItems) { item in
                                    HStack {
                                        Text("\(item.vehicle ?? "")")
                                        Spacer()
                                        Text("\(item.weight) kg")
                                        if isAddMode {
                                            Button(action: { vehicleViewModel.deleteVehicleItem(item: item) }) {
                                                Image(systemName: "trash")
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(8)
                                    .contentShape(Rectangle()) // HStack 전체 영역을 클릭 가능하게 함
                                    .onTapGesture {
                                        if !isAddMode {
                                            onSelectVehicle?(item)
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            .navigationBarBackButtonHidden(true).padding()
                .onAppear {
                    switch listType {
                    case .product:
                        productViewModel.fetchProductItems()
                    case .client:
                        clientViewModel.fetchClientItems()
                    case .vehicle:
                        vehicleViewModel.fetchVehicleItems()
                    }
                }
        }
    }
    
    private var titleText: String {
        switch listType {
        case .product:
            return productViewModel.text
        case .client:
            return clientViewModel.text
        case .vehicle:
            return vehicleViewModel.text
        }
    }
}

