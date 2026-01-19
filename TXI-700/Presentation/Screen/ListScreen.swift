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
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var onSelectProduct: () ->Void
    var onSelectClient: () -> Void
    var onSelectVehicle: () -> Void
    
    var body: some View {
        VStack{
            if isAddMode {
                HStack {
                    switch listType {
                    case .product:
                        CustomPlaceholderTextField(
                            placeholder: "product".localized(languageManager.selectedLanguage),
                            text: $productViewModel.name).padding(.leading)
                        
                        let productNum: Int = {
                            if let num = productViewModel.selectedProduct?.shortcutNum {
                                return Int(num) + 1
                            } else {
                                return productViewModel.productItems.count
                            }
                        }()
                        
                        SaveOrUpdateButton(
                            title: productViewModel.selectedProduct == nil ? "Save".localized(languageManager.selectedLanguage) : "Update".localized(languageManager.selectedLanguage),
                            onButton:{
                                let name = productViewModel.name
                                
                                guard !name.isEmpty else {
                                    activeAlert = .error("ProductError".localized(languageManager.selectedLanguage))
                                    return
                                }
                                bleManager.sendCommand(.bti(num: productNum+1, name: name), log: "Item Save Send")
                                productViewModel.saveOrUpdateProcduct()
                            }
                        ).padding(.trailing)
                        if productViewModel.selectedProduct != nil {
                            Button {
                                productViewModel.clearSelection()
                            } label: {
                                Text("Cancel")
                                    .foregroundColor(.red)
                                    .contentShape(Rectangle())
                            }
                        }
                    case .client:
                        CustomPlaceholderTextField(
                            placeholder: "client".localized(languageManager.selectedLanguage),
                            text: $clientViewModel.name).padding(.leading)
                        
                        let clientNum: Int = {
                            if let num = clientViewModel.selectedClient?.shortcutNum {
                                return Int(num) + 1
                            } else {
                                return clientViewModel.clientItems.count
                            }
                        }()
                        SaveOrUpdateButton(
                            title: clientViewModel.selectedClient == nil ? "Save".localized(languageManager.selectedLanguage) : "Update".localized(languageManager.selectedLanguage),
                            onButton:{
                                let name = clientViewModel.name
                                
                                guard !name.isEmpty else {
                                    activeAlert = .error("ClientError".localized(languageManager.selectedLanguage))
                                    return
                                }
                                bleManager.sendCommand(.bti(num: clientNum+1, name: name), log: "Client Save Send")
                                clientViewModel.saveOrUpdateClient()
                            }
                        ).padding(.trailing)
                        if clientViewModel.selectedClient != nil {
                            Button {
                                clientViewModel.clearSelection()
                            } label: {
                                Text("Cancel")
                                    .foregroundColor(.red)
                                    .contentShape(Rectangle())
                            }
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
                                ZStack {
                                    if productViewModel.selectedProduct?.id == item.id {
                                        Color.blue.opacity(0.15)
                                            .cornerRadius(6)
                                    }
                                    Button {
                                        if !isAddMode {
                                            onSelectProduct()
                                            productViewModel.selectProduct(item)
                                            bleManager.sendCommand(.btq(Int(item.shortcutNum)+1), log: "ItemCheck")
                                        } else {
                                            productViewModel.selectProduct(item)
                                        }
                                    } label: {
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
                                                .contentShape(Rectangle())
                                            }
                                        }
                                        .padding(8)
                                    }
                                    .buttonStyle(.plain)
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
                                ZStack {
                                    if clientViewModel.selectedClient?.id == item.id {
                                        Color.blue.opacity(0.15)
                                            .cornerRadius(6)
                                    }
                                    Button {
                                        if !isAddMode {
                                            onSelectClient()
                                            clientViewModel.selectClient(item)
                                            bleManager.sendCommand(.btg(Int(item.shortcutNum)+1), log: "ClientCheck")
                                        } else {
                                            clientViewModel.selectClient(item)
                                        }
                                    } label: {
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
                                                .contentShape(Rectangle())
                                            }
                                        }
                                        .padding(8)
                                    }
                                    .buttonStyle(.plain)
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
                                ZStack {
                                    if vehicleViewModel.selectedVehicle?.id == item.id {
                                        Color.blue.opacity(0.15)
                                            .cornerRadius(6)
                                    }
                                    Button {
                                        if !isAddMode {
                                            onSelectVehicle()
                                            vehicleViewModel.selectVehicle(item)
                                        } else {
                                            vehicleViewModel.selectVehicle(item)
                                        }
                                    } label: {
                                        HStack {
                                            Text("\(item.num + 1)")
                                            Spacer()
                                            Text(item.vehicle ?? "")
                                            Spacer()
                                            Text("\(item.weight) kg")
                                            
                                            if isAddMode {
                                                Button {
                                                    vehicleViewModel.deleteVehicleItem(item: item)
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(.borderless)
                                                .contentShape(Rectangle())
                                            }
                                        }
                                        .padding(8)
                                    }
                                    .buttonStyle(.plain)
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
                activeAlert = nil
            }.alert(item: $activeAlert) { alertType in
                Alert(
                    title: Text(""),
                    message: Text(alertType.message),
                    dismissButton: .default(Text("Confirmation"))
                )
            }
        }.safeAreaInset(edge: .top) {
            CustomListTopBar(title: titleText,onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onChange: { newMode in
                isAddMode = !newMode
                //                guard !isAddMode else { return }
                switch listType {
                case .product:
                    productViewModel.clearSelection()
                case .client:
                    clientViewModel.clearSelection()
                case .vehicle:
                    vehicleViewModel.clearSelection()
                }
                print("현재 모드:", newMode ? "X" : "Add")
            })
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

