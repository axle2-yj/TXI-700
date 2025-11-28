//
//  MainScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct MainScreen: View {
    @State private var goToSetting = false
    @State private var goToList = false
    @State private var goToData = false
    @State private var selectedListType: ListType? = nil
    @State private var selectedProduct: ProductInfo? = nil
    @State private var selectedClient: ClientInfo? = nil
    @State private var selectedVehicle: VehicleInfo? = nil
    @State private var loadAxleStatus: [LoadAxleStatus] = []
    @State private var totalSumValue: Int = 0 // SUM 버튼 클릭 시 저장
    @State private var isSum: Bool = false

    @StateObject var productViewModel = ProductViewModel()
    @StateObject var clientViewModel = ClientViewModel()
    @StateObject var vehicleViewModel = VehicleViewModel()
    @StateObject var mainViewModel = MainViewModel()
    @StateObject private var clockManager = ClockManager()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BluetoothManager
    


    init() {
        _productViewModel = StateObject(wrappedValue: ProductViewModel())
        _clientViewModel = StateObject(wrappedValue: ClientViewModel())
        _vehicleViewModel = StateObject(wrappedValue: VehicleViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomTopBar(title: mainViewModel.text,onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onSettings: {
                goToSetting = true
            }
            )
                VStack {
                    VStack {
                        ClockView(currentTime: $clockManager.currentTime)

                        HStack {
                            Text("\(bleManager.loadAxle1BatteryLevel ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("%").font(.system(size: 25))
                            Spacer()
                            Text("\(bleManager.loadAxel1 ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("kg").font(.system(size: 25))

                        }
                        HStack {
                            Text("\(bleManager.loadAxle1BatteryLevel ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("%").font(.system(size: 25))
                            Spacer()
                            Text("\(bleManager.loadAxel2 ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("kg").font(.system(size: 25))
                        }
                        HStack {
                            Text("\(bleManager.loadAxle1BatteryLevel ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("%").font(.system(size: 25))
                            Spacer()
                            Text("\((bleManager.loadAxel1 ?? 0) + (bleManager.loadAxel2 ?? 0))").font(Font.custom("TI-1700FONT", size: 25.0))
                            Text("kg").font(.system(size: 25))
                        }
                    }
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("No").font(.system(size: 25))
                            Spacer()
                            Text("LEFT").font(.system(size: 25))
                            Spacer()
                            Text("RIGHT").font(.system(size: 25))
                            Spacer()
                            Text("TOTAL").font(.system(size: 25))
                        }.background(Color.gray.opacity(0.1))
                        if !loadAxleStatus.isEmpty {
                            ForEach(loadAxleStatus) { loadAxle in
                                HStack {
                                    Text("\(loadAxle.id)").font(Font.custom("TI-1700FONT", size: 25.0))
                                    Spacer()
                                    Text("\(loadAxle.loadAxlesData.first ?? 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                                    Text("kg").font(.system(size: 25))
                                    Spacer()
                                    Text("\(loadAxle.loadAxlesData.count > 1 ? loadAxle.loadAxlesData[1] : 0)").font(Font.custom("TI-1700FONT", size: 25.0))
                                    Text("kg").font(.system(size: 25))
                                    Spacer()
                                    Text("\(loadAxle.total)").font(Font.custom("TI-1700FONT", size: 25.0))
                                    Text("kg").font(.system(size: 25))
                                }
                                .padding(5)
                                .onAppear {
                                    print(loadAxle.loadAxlesData)
                                }
                                Divider() // List 하단 라인
                                    .background(Color.gray)
                                    .frame(height: 1)
                            }
                        }

                        Spacer()
                        HStack {
                            Text("S/N : ")
                            Spacer()
                            Text("TOTAL : \(totalSumValue) kg")
                        }
                    }.padding()
                    
                    HStack {
                        Button("Car.no") {
                            selectedListType = .vehicle
                            goToList = true
                        }
                        TextField("Car Number", text: .constant("\(selectedVehicle?.vehicle ?? "")"))
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Button("\(selectedProduct?.name ?? mainViewModel.saveProduct ?? "ITEM <<")") {
                            selectedListType = .product
                            goToList = true
                        }
                        
                        Button("\(selectedClient?.name ?? mainViewModel.saveCliant ?? "CLIANT <<")") {
                            selectedListType = .cliant
                            goToList = true
                        }
                    }
                    
                    HStack {
                        ZeroButton()
                        if !isSum {
                            EnterButton(loadAxleStatus: $loadAxleStatus)
                            SumButton(onSum: {
                                isSum = true
                                totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                            }).disabled(loadAxleStatus.count < 2)   // 2개 이상이면 활성화
                                .opacity(loadAxleStatus.count < 2 ? 0.4 : 1.0) // 비활성 시 시각적으로 흐리게
                        } else {
                            PrintButton()
                            SaveButton(
                                loadAxleStatus: $loadAxleStatus,
                                client: "\(mainViewModel.saveCliant ?? "")",
                                product: "\(mainViewModel.saveProduct ?? "")",
                                vehicle: "\(selectedVehicle?.vehicle ?? "")"
                            )
                        }
                    }
                    
                    HStack {
                        Button("DATA") {
                            goToData = true
                        }
                    }
                    Spacer()
                
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToSetting){
                SettingScreen()
            }.navigationDestination(isPresented: $goToList) {
                if let type = selectedListType {
                    ListScreen(listType: type,
                               productViewModel: productViewModel,
                               clientViewModel: clientViewModel,
                               vehicleViewModel: vehicleViewModel,
                               onSelectProduct: { product in
                        selectedProduct = product
                        goToList = false
                    },
                               onSelectClient: { client in
                        selectedClient = client
                        goToList = false
                    },
                               onSelectVehicle: { vehicle in
                        selectedVehicle = vehicle
                        goToList = false
                    }
                    )
                }
            }.onAppear {
                mainViewModel.loadProduct()
                mainViewModel.loadClient()
            }.navigationDestination(isPresented: $goToData) {
                DataScreen()
            }
    }
}

#Preview {
    MainScreen()
}
