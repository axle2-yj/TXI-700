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
    @State private var isPrint: Bool = false
    @State private var isSave: Bool = false
    @State private var printResponse: String = ""
    @State private var showPrintPopup = false
    @State private var popupMessage = ""

    @StateObject var productViewModel = ProductViewModel()
    @StateObject var clientViewModel = ClientViewModel()
    @StateObject var vehicleViewModel = VehicleViewModel()
    @StateObject var mainViewModel = MainViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    @StateObject var printViewModel = PrintFormSettingViewModel()
    @StateObject var dataViewModel = DataViewModel()
    @StateObject private var clockManager = ClockManager()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BluetoothManager
    @EnvironmentObject var languageManager: LanguageManager
    


    init() {
        _productViewModel = StateObject(wrappedValue: ProductViewModel())
        _clientViewModel = StateObject(wrappedValue: ClientViewModel())
        _vehicleViewModel = StateObject(wrappedValue: VehicleViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomMainTopBar(title: mainViewModel.text,onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onSettings: {
                goToSetting = true
            }, viewModel: settingViewModel)
            .onReceive(bleManager.$modeChangeInt) { newValue in
                settingViewModel.saveModeChange(newValue)
                settingViewModel.loadModeChange()
            }
            VStack {
                    VStack {
                        ClockView(currentTime: $clockManager.currentTime)
                        if settingViewModel.weightingMethod == 3 {
                            VStack {
                                HStack {
                                    BatteryLevelBalanceView(
                                        number: 1,
                                        level: bleManager.loadAxle1BatteryLevel ?? 0,
                                        divice: "LEFT1",
                                        axleWight: bleManager.leftLoadAxel1 ?? 0)
                                    
                                    BatteryLevelBalanceView(
                                        number: 2,
                                        level: bleManager.loadAxle2BatteryLevel ?? 0,
                                        divice: "RIGHT1",
                                        axleWight: bleManager.rightLoadAxel1 ?? 0)
                                }
                                HStack {
                                    BatteryLevelBalanceView(
                                        number: 3,
                                        level: bleManager.loadAxle3BatteryLevel ?? 0,
                                        divice: "LEFT2",
                                        axleWight: bleManager.leftLoadAxel2 ?? 0)
                                
                                    BatteryLevelBalanceView(
                                        number: 4,
                                        level: bleManager.loadAxle4BatteryLevel ?? 0,
                                        divice: "RIGHT2",
                                        axleWight: bleManager.rightLoadAxel2 ?? 0)
                                    }
                                BatteryLevelBalanceView(
                                    number: 5,
                                    level: bleManager.indicatorBatteryLevel ?? 0,
                                    divice: "Total",
                                    axleWight: (bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0) + (bleManager.leftLoadAxel2 ?? 0) + (bleManager.rightLoadAxel2 ?? 0))

                            }
                        } else {
                            BatteryLevelLoadAxleWeightView(level: bleManager.loadAxle1BatteryLevel ?? 0, divice: "LEFT:", axleWight: String(bleManager.leftLoadAxel1 ?? 0))
                            BatteryLevelLoadAxleWeightView(level: bleManager.loadAxle2BatteryLevel ?? 0, divice: "RIGHT:", axleWight: String(bleManager.rightLoadAxel1 ?? 0))
                            BatteryLevelLoadAxleWeightView(level: bleManager.indicatorBatteryLevel ?? 0, divice: "AXLE:", axleWight: String(String((bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0))))
                        }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    if settingViewModel.weightingMethod != 3 {
                        HStack {
                            Text("No").font(.system(size: 25))
                            Spacer()
                            Text("LEFT").font(.system(size: 25))
                            Spacer()
                            Text("RIGHT").font(.system(size: 25))
                            Spacer()
                            Text("AXLE").font(.system(size: 25))
                        }.background(Color.gray.opacity(0.1))
                    } else {
                        
                    }
                    if !loadAxleStatus.isEmpty {
                        ForEach(loadAxleStatus) { loadAxle in
                            let rowCount = (loadAxle.loadAxlesData.count + 1) / 2  // 2개씩 묶어서 몇 줄 필요한지
                            
                            ForEach(0..<rowCount, id: \.self) { rowIndex in
                                let firstIndex = rowIndex * 2
                                let secondIndex = firstIndex + 1
                                
                                let firstValue = loadAxle.loadAxlesData.indices.contains(firstIndex) ? loadAxle.loadAxlesData[firstIndex] : 0
                                let secondValue = loadAxle.loadAxlesData.indices.contains(secondIndex) ? loadAxle.loadAxlesData[secondIndex] : 0
                                
                                HStack {
                                    Text("\(loadAxle.id + rowIndex)")
                                    Spacer()
                                    Text(String(firstValue)).font(Font.custom("TI-1700FONT", size: 25))
                                    Text("kg").font(.system(size: 25))
                                    Spacer()
                                    Text(String(secondValue)).font(Font.custom("TI-1700FONT", size: 25))
                                    Text("kg").font(.system(size: 25))
                                    Spacer()
                                    Text(String(firstValue + secondValue)).font(Font.custom("TI-1700FONT", size: 25))
                                    Text("kg").font(.system(size: 25))
                                }
                                .padding(5)
                                Divider()
                            }
                        }
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Text("S/N : ")
                            Spacer()
                            Text("TOTAL : \(totalSumValue) kg")
                        }
                        HStack {
                            if settingViewModel.weightingMethod == 2 {
                                Text("1stWeight" + " : ")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Text(String(selectedVehicle?.weight ?? 0))
                                    .lineLimit(1)
                                Text("kg")
                                Spacer()
                                Text("NetWeight").lineLimit(1)
                                    .truncationMode(.tail)
                                Text(String(Int64(totalSumValue) - (selectedVehicle?.weight ?? 0))).lineLimit(1)
                                Text("kg")
                            }
                        }
                    }
                    
                }.padding()
                
                HStack {
                    Button("Car.no") {
                        selectedListType = .vehicle
                        goToList = true
                    }.padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.black)
                    
                    TextField("Car Number", text: .constant("\(selectedVehicle?.vehicle ?? "")"))
                        .textFieldStyle(.roundedBorder)
                    
                    Button(settingViewModel.weightingMethod != 2 ? "Send" : "1stWeight") {
                        
                    }.padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.black)
                    
                }
                
                HStack {
                    if settingViewModel.checkedProduct {
                        Button("\(selectedProduct?.name ?? mainViewModel.saveProduct ?? "ITEM <<")") {
                            selectedListType = .product
                            goToList = true
                        }.frame(maxWidth: .infinity) // 화면 절반 차지
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                    }
                    
                    if settingViewModel.checkedClient {
                        Button("\(selectedClient?.name ?? mainViewModel.saveClient ?? "CLIENT <<")") {
                            selectedListType = .client
                            goToList = true
                        }.frame(maxWidth: .infinity) // 화면 절반 차지
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                    }
                }
                
                HStack {
                    ZeroButton()
                    if !isSum {
                        let isSumEnabled = (loadAxleStatus.last?.loadAxlesData.indices.contains(2) ?? false) && (loadAxleStatus.last?.loadAxlesData[2] ?? 0) != 0
                        
                        EnterButton(
                            viewModel: settingViewModel,
                            loadAxleStatus: $loadAxleStatus
                        )
                        
                        SumButton(onSum: {
                            isSum = true
                            totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                        }).disabled(!isSumEnabled)
                            .opacity(isSumEnabled ? 1.0 : 0.4)
                    } else {
                        PrintButton(
                            isMain: true,
                            seletedType: 0,
                            viewModel: dataViewModel,
                            printResponse: $printResponse,
                            lines: []
                        )
                        .disabled(isPrint)
                        .opacity(isPrint ? 1.0 : 0.4)
                        
                        
                        SaveButton(loadAxleStatus: $loadAxleStatus,
                                   client: "\(selectedClient?.name ?? "")",
                                   product: "\(selectedProduct?.name ?? "")",
                                   vehicle: "\(selectedVehicle?.vehicle ?? "")",
                                   serialNumber : "",          // 시리얼 넘버 저장 필요
                                   equipmentNumber : "",       // 장치 고유번호 저장 필요
                        )
                    }
                }.onReceive(bleManager.$printResponse) { newVelue in
                    if newVelue.isEmpty { return }
                    popupMessage = newVelue
                    showPrintPopup = true
                }
                
                HStack {
                    Button("DATA") {
                        goToData = true
                    }.frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.black)
                    if isSum {
                        Button("CENCEL") {
                            loadAxleStatus = []
                            isSave = false
                            isSum = false
                            isPrint = false
                            totalSumValue = 0
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToSetting){
            SettingScreen(viewModel: settingViewModel, printViewModel: printViewModel)
                .environmentObject(languageManager)
        }.navigationDestination(isPresented: $goToList) {
            if let type = selectedListType {
                ListScreen(listType: type,
                           productViewModel: productViewModel,
                           clientViewModel: clientViewModel,
                           vehicleViewModel: vehicleViewModel,
                           printViewModel: printViewModel,
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
            DispatchQueue.main.async {
                mainViewModel.loadProduct()
                mainViewModel.loadClient()
                mainViewModel.startTimer(bleManager: bleManager)
            }
            settingViewModel.loadLanguage()
            settingViewModel.loadWeightingMethod()
            settingViewModel.loadModeChange()
            settingViewModel.loadProductCkeck()
            settingViewModel.loadClientCkeck()
        }.navigationDestination(isPresented: $goToData) {
                DataScreen(printViewModel: printViewModel)
        }
        .alert(isPresented: $showPrintPopup) {
            Alert(
                title: Text(""),
                message: Text(popupMessage),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        okButtonAction()
                    }
                )
            )
        }
    }
    
    func okButtonAction() {
        if isSave && isPrint {
            loadAxleStatus = []
            isSave = false
            isSum = false
            isPrint = false
            totalSumValue = 0
        }
    }
}

#Preview {
    MainScreen()
}


