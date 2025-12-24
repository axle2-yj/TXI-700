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
    @State private var activeAlert: ActiveListAlert?

    @ObservedObject var productViewModel: ProductViewModel
    @ObservedObject var clientViewModel: ClientViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) private var editMode
    
    @EnvironmentObject var bleManager: BluetoothManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var onSelectProduct: ((ProductInfo) ->Void)?
    var onSelectClient: ((ClientInfo) -> Void)?
    var onSelectVehicle: ((VehicleInfo) -> Void)?
    
    var body: some View {
        VStack{
            if isAddMode {
                HStack {
                    switch listType {
                    case .product:
                        TextField("product", text: $productViewModel.name)
                            .textFieldStyle(.roundedBorder)
                        let productNum: Int = {
                            if let num = productViewModel.selectedProduct?.num {
                                return Int(num)
                            } else {
                                return productViewModel.productItems.count
                            }
                        }()
                        
                        SaveOrUpdateButton(
                            title: productViewModel.selectedProduct == nil ? "Save".localized(languageManager.selectedLanguage) : "Update".localized(languageManager.selectedLanguage),
                            onButton:{
                                let name = productViewModel.name
                                let type: BLEItemType = .product
                                
                                guard !name.isEmpty else {
                                    activeAlert = .error("ProductError".localized(languageManager.selectedLanguage))
                                    return
                                }
                                
                                let bytes = makePacket(
                                    type: type,
                                    num: productNum + 1,
                                    name: name
                                )
                                
                                print("Product name : \(name)")
                                print("Product save send : \(bleManager.sendData(bytes))")
                                
                                productViewModel.saveOrUpdateProcduct()
                            }
                        )
                        if productViewModel.selectedProduct != nil {
                                    Button("Cancel") {
                                        productViewModel.clearSelection()
                                    }
                                    .foregroundColor(.red)
                                }
                    case .client:
                        TextField("client", text: $clientViewModel.name)
                            .textFieldStyle(.roundedBorder)
                        let clientNum: Int = {
                            if let num = clientViewModel.selectedClient?.num {
                                return Int(num)
                            } else {
                                return clientViewModel.clientItems.count
                            }
                        }()
                        SaveOrUpdateButton(
                            title: clientViewModel.selectedClient == nil ? "Save".localized(languageManager.selectedLanguage) : "Update".localized(languageManager.selectedLanguage),
                            onButton:{
                                let name = clientViewModel.name
                                let type: BLEItemType = .client
                                
                                guard !name.isEmpty else {
                                    activeAlert = .error("ClientError".localized(languageManager.selectedLanguage))
                                    return
                                }
                                
                                let bytes = makePacket(
                                    type: type,
                                    num: clientNum + 1,
                                    name: name
                                )
                                print("Client save send : \(bleManager.sendData(bytes))")
                                clientViewModel.saveOrUpdateClient()
                            }
                        )
                        if clientViewModel.selectedClient != nil {
                                    Button("Cancel") {
                                        clientViewModel.clearSelection()
                                    }
                                    .foregroundColor(.red)
                                }
                    case .vehicle:
                        VehicleRegionDropdown(viewModel: vehicleViewModel, activeAlert: $activeAlert)
                            .onAppear {
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
                                    Text("\(item.num+1)")
                                    Spacer()
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
                                .background(
                                            productViewModel.selectedProduct == item
                                            ? Color.blue.opacity(0.15)
                                            : Color.clear
                                        )
                                .onTapGesture {
                                    if !isAddMode {
                                        bleManager.sendInitialItemCommand(
                                            num: Int(item.num+1)
                                        )
                                        onSelectProduct?(item)
                                    } else {
                                        productViewModel.selectProduct(item)
                                    }
                                }
                            }.onMove { from, to in
                                if isAddMode {
                                    productViewModel.moveProduct(from: from, to: to)
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
                                    Text("\(item.num+1)")
                                    Spacer()
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
                                .contentShape(Rectangle())
                                .background(
                                            clientViewModel.selectedClient == item
                                            ? Color.blue.opacity(0.15)
                                            : Color.clear
                                        )
                                .onTapGesture {
                                    if !isAddMode {
                                        bleManager.sendInitialClientCommand(
                                            num: Int(item.num+1)
                                        )
                                        onSelectClient?(item)
                                    } else {
                                        clientViewModel.selectClient(item)
                                    }
                                }
                            }.onMove { from, to in
                                if isAddMode {
                                    clientViewModel.moveClient(from: from, to: to)
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
                            ForEach(vehicleViewModel.vehicleItems.sorted { $0.num < $1.num }) { item in
                                HStack {
                                    Text("\(item.num+1)")
                                    Spacer()
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
                                .background(
                                            vehicleViewModel.selectedVehicle == item
                                            ? Color.blue.opacity(0.15)
                                            : Color.clear
                                        )
                                .onTapGesture {
                                    if !isAddMode {
                                        onSelectVehicle?(item)
                                    } else {
                                        vehicleViewModel.selectVehicle(item)
                                    }
                                }
                            }.onMove { from, to in
                                if isAddMode {
                                    vehicleViewModel.moveVechile(from: from, to: to)
                                }
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                CustomListTopBar(title: titleText,onBack: {
                    presentationMode.wrappedValue.dismiss()
                }, onChange: {
                    newMode in
                            isAddMode = !newMode
                            print("현재 모드:", newMode ? "X" : "Add")
                })
            }
            .navigationBarHidden(true)
            .padding()
            .onAppear {
                switch listType {
                case .product:
                    productViewModel.fetchProductItems()
                case .client:
                    clientViewModel.fetchClientItems()
                case .vehicle:
                    vehicleViewModel.fetchVehicleItems()
                }
            }.onDisappear {
                clientViewModel.clearSelection()
                productViewModel.clearSelection()
                vehicleViewModel.clearSelection()
                activeAlert = nil
            }.alert(item: $activeAlert) { alertType in
                Alert(
                    title: Text(""),
                    message: Text(alertType.message),
                    dismissButton: .default(Text("Confirmation"))
                )
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

