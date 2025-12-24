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
    @State private var twoStepLoadAxleStatus: [LoadAxleStatus] = []
    @State private var totalSumValue: Int = 0
    @State private var isMainSum: Bool = false
    @State private var isTwoStep: Bool = false
    @State private var isPrint: Bool = false
    @State private var isSave: Bool = false
    @State private var printResponse: String = ""
    @State private var activeAlert: ActiveMainAlert?
    @State private var isPrinting: Bool = false
    @State private var weighting1stData = 0
    @State private var netWeightData = 0
    @State private var vehicleNumber: String = ""
    @State private var selectNum = 0
    @State private var enterError = ""
    @State private var isAlertShowing: Bool = false
    @State private var vehicleNum = ""
    @State private var saveValue = 0
    
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
        ZStack {
            VStack(spacing: 3) {
                ClockView(currentTime: $clockManager.currentTime)
                VStack(spacing: 3) {
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
                                divice: "TOTAL",
                                axleWight: (bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0) + (bleManager.leftLoadAxel2 ?? 0) + (bleManager.rightLoadAxel2 ?? 0))
                        }
                    } else {
                        BatteryLevelLoadAxleWeightView(level: bleManager.loadAxle1BatteryLevel ?? 0, divice: "LEFT:", axleWight: String(bleManager.leftLoadAxel1 ?? 0))
                        BatteryLevelLoadAxleWeightView(level: bleManager.loadAxle2BatteryLevel ?? 0, divice: "RIGHT:", axleWight: String(bleManager.rightLoadAxel1 ?? 0))
                        BatteryLevelLoadAxleWeightView(level: bleManager.indicatorBatteryLevel ?? 0, divice: "AXLE:", axleWight: String(String((bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0))))
                    }
                }
                let noWidth: CGFloat = 35
                VStack(alignment: .leading, spacing: 5) {
                    if settingViewModel.weightingMethod != 3 {
                        HStack {
                            Text("No")
                                .frame(width: noWidth, alignment: .leading)

                            Text("LEFT")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .layoutPriority(1)

                            Text("RIGHT")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .layoutPriority(1)

                            Text("AXLE")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .layoutPriority(1)
                        }
                        .font(.system(size: 25))
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        
                        ScrollView {
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
                                                .frame(width: noWidth, alignment: .leading)

                                            MainWeightText(value: firstValue)

                                            MainWeightText(value: secondValue)

                                            MainWeightText(value: firstValue + secondValue)
                                        }
                                        .lineLimit(1)
                                        .padding(.vertical, 5)
                                        Divider()

                                    }
                                }
                            }
                        }
                    } else {
                        WeightBalanceView(
                                left1: CGFloat(bleManager.leftLoadAxel1 ?? 0),
                                right1: CGFloat(bleManager.rightLoadAxel1 ?? 0),
                                left2: CGFloat(bleManager.leftLoadAxel2 ?? 0),
                                right2: CGFloat(bleManager.rightLoadAxel2 ?? 0)
                        )
                        .frame(height: 300)
                        .padding()
                        
                    }
                }.padding()
                Spacer()
            }
            .safeAreaInset(edge: .top) {
                CustomMainTopBar(title: mainViewModel.text,onBack: {
                    presentationMode.wrappedValue.dismiss()
                }, onSettings: {
                    goToSetting = true
                }, viewModel: settingViewModel)
                .onReceive(bleManager.$modeChangeInt) { newValue in
                    settingViewModel.saveModeChange(newValue)
                    settingViewModel.loadModeChange()
                }.onAppear {
                    DispatchQueue.main.async {
                        mainViewModel.loadProduct()
                        mainViewModel.loadClient()
                        mainViewModel.startTimer(bleManager: bleManager)
                    }
                    mainViewModel.loadSn()
                    settingViewModel.loadLanguage()
                    settingViewModel.loadWeightingMethod()
                    settingViewModel.loadModeChange()
                    settingViewModel.loadProductCkeck()
                    settingViewModel.loadClientCkeck()
                    settingViewModel.loadPrintOutputCountSetting()
                }
                
            }
            .safeAreaInset(edge: .bottom, alignment: .center) {
                VStack(spacing: 3){
                    if settingViewModel.weightingMethod != 3 {
                        VStack {
                            HStack {
                                Text("S/N : \(mainViewModel.sn)")
                                Spacer()
                                Text("TOTAL : \(totalSumValue) kg")
                            }.padding(.horizontal, 20)
                                .font(Font.system(size: 25, weight: .bold, design: .default))
                            
                            HStack {
                                let weighting1stvalue = selectedVehicle?.weight == nil ? weighting1stData : 0
                                if settingViewModel.weightingMethod == 2 {
                                    Text("1stWeight")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text(" : ")
                                    Text(String(weighting1stvalue))
                                        .lineLimit(1)
                                    Text("kg")
                                    Spacer()
                                    Text("NetWeight").lineLimit(1)
                                        .truncationMode(.tail)
                                    Text(String(netWeightData)).lineLimit(1)
                                    Text("kg")
                                }
                            }.padding(.horizontal, 20)
                                .font(Font.system(size: 25, weight: .bold, design: .default))
                        }
                        
                        HStack {
                            Button("Car.no") {
                                selectedListType = .vehicle
                                goToList = true
                            }.padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(.black)
                            
                            TextField("Car Number", text: $vehicleNum)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: selectedVehicle) { newValue, _ in
                                    vehicleNum = newValue?.vehicle ?? ""
                                }
                            
                            
                            Button(settingViewModel.weightingMethod != 2 ? "Send" : "1stWeight") {
                                if settingViewModel.weightingMethod == 2 {
                                    let total = loadAxleStatus.reduce(0) { $0 + $1.total }
                                    loadAxleStatus[0].loadAxlesData = [total]
                                    twoStepLoadAxleStatus = loadAxleStatus
                                    weighting1stData = loadAxleStatus.reduce(0) { $0 + $1.total }
                                    isTwoStep = true
                                    isMainSum = false
                                    okButtonAction()
                                } else if settingViewModel.weightingMethod == 0{
                                    let type: BLEItemType = .vechicle
                                    
                                    let bytes = makePacket(
                                        type: type,
                                        num: 0,
                                        name: vehicleNum
                                    )
                                    print("Vehicle save send : \(bleManager.sendData(bytes))")
                                }
                            }.padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(.black)
                                .disabled(
                                    (!isMainSum &&
                                     isTwoStep) ||
                                    vehicleNum.isEmpty
                                )
                                .opacity(
                                    (isMainSum && isTwoStep) || !vehicleNum.isEmpty
                                    ? 1.0
                                    : 0.4
                                )
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
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        HStack {
                            ZeroButton()
                            Button("DATA") {
                                goToData = true
                                bleManager.sendInitialSaveDataCommand()
                            }.frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(.black)
                            if isMainSum {
                                Button("CANCEL") {
                                    okButtonAction()
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        HStack {
                            if !isMainSum {
                                let isSumEnabled = (loadAxleStatus.last?.loadAxlesData.indices.contains(1) ?? false) && (loadAxleStatus.last?.loadAxlesData[1] ?? 0) != 0
                                EnterButton(
                                    viewModel: settingViewModel,
                                    loadAxleStatus: $loadAxleStatus,
                                    onEnter: {
                                        let weighting1stvalue = selectedVehicle?.weight == nil ? weighting1stData : 0
                                        if settingViewModel.weightingMethod == 2 {
                                            totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                                            netWeightData = totalSumValue - weighting1stvalue
                                        }
                                    },
                                    onEnterMassege: {
                                        if !isAlertShowing {
                                            isAlertShowing = true
                                            activeAlert = .error("error3".localized(languageManager.selectedLanguage))
                                        }
                                    }
                                )
                                if settingViewModel.weightingMethod == 2 {
                                    TwoStepSumButton(onSum: {
                                        totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                                    }).disabled(!isSumEnabled)
                                        .opacity(isSumEnabled ? 1.0 : 0.4)
                                } else {
                                    SumButton(onSum: {
                                        totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                                    }).disabled(!isSumEnabled)
                                        .opacity(isSumEnabled ? 1.0 : 0.4)
                                }
                            } else {
                                let weightingMethodInt = settingViewModel.weightingMethod
                                let lines: [String] = if weightingMethodInt == 0 {
                                    []
                                } else if weightingMethodInt == 2{
                                    PrintLineBuilder.buildThird(
                                        weighting1st: weighting1stData,
                                        weighting2nd: totalSumValue,
                                        netWeight: netWeightData,
                                        dataViewModel: dataViewModel,
                                        printViewModel: printViewModel,
                                        timeStamp: Date(),
                                        item: selectedProduct?.name ?? mainViewModel.saveProduct ?? "N/A",
                                        client : selectedClient?.name ?? mainViewModel.saveClient ?? "N/A",
                                        vehicle : selectedVehicle?.vehicle ?? "N/A",
                                        serialNumber: String(mainViewModel.sn),
                                        selectedType: weightingMethodInt
                                    )
                                } else {
                                    PrintLineBuilder.buildSecond(
                                        loadAxleItem: loadAxleStatus,
                                        dataViewModel: dataViewModel,
                                        printViewModel: printViewModel,
                                        timeStamp: Date(),
                                        item: selectedProduct?.name ?? mainViewModel.saveProduct ?? "N/A",
                                        client : selectedClient?.name ?? mainViewModel.saveClient ?? "N/A",
                                        vehicle : selectedVehicle?.vehicle ?? "N/A",
                                        serialNumber: String(mainViewModel.sn),
                                        selectedType: weightingMethodInt
                                    )
                                }
                                
                                PrintButton(
                                    isMain: true,
                                    seletedType: $selectNum,
                                    viewModel: dataViewModel,
                                    printViewModel: printViewModel,
                                    settingViewModel: settingViewModel,
                                    printResponse: $printResponse,
                                    lines: lines,
                                    onPrint: {
                                        isPrinting = true
                                        if weightingMethodInt != 0 {
                                            let type: BLEItemType = .vechicle
                                            
                                            let bytes = makePacket(
                                                type: type,
                                                num: 0,
                                                name: vehicleNum
                                            )
                                            print("Vehicle save send : \(bleManager.sendData(bytes))")
                                        }
                                    },
                                    offPrint: {
                                        if weightingMethodInt == 2 {
                                            twoStepLoadAxleStatus[0].loadAxlesData.append(loadAxleStatus[0].total)
                                            twoStepLoadAxleStatus[0].total = twoStepLoadAxleStatus[0].total + loadAxleStatus[0].total
                                            print(twoStepLoadAxleStatus)
                                            if !isSave {
                                                LoadAxleSaveService.printSaveData(
                                                    serialNumber: String(mainViewModel.sn),
                                                    equipmentNumber: String(bleManager.equipmentNumber),
                                                    client: selectedClient?.name ?? mainViewModel.saveClient ?? "N/A",
                                                    product: selectedProduct?.name ?? mainViewModel.saveProduct ?? "N/A",
                                                    vehicle: selectedVehicle?.vehicle ?? "N/A",
                                                    weightNum: String(weightingMethodInt),
                                                    loadAxleStatus: twoStepLoadAxleStatus
                                                ) {
                                                    isPrinting = false
                                                    netWeightData = 0
                                                    weighting1stData = 0
                                                    isTwoStep = false
                                                    printInitial()
                                                }
                                            } else {
                                                isPrinting = false
                                                netWeightData = 0
                                                weighting1stData = 0
                                                printInitial()
                                            }
                                            
                                        } else {
                                            if !isSave {
                                                print("print save 실행")
                                                LoadAxleSaveService.printSaveData(
                                                    serialNumber: String(mainViewModel.sn),
                                                    equipmentNumber: String(bleManager.equipmentNumber),
                                                    client: selectedClient?.name ?? mainViewModel.saveClient ?? "N/A",
                                                    product: selectedProduct?.name ?? mainViewModel.saveProduct ?? "N/A",
                                                    vehicle: selectedVehicle?.vehicle ?? "N/A",
                                                    weightNum: String(weightingMethodInt),
                                                    loadAxleStatus: loadAxleStatus
                                                ) {
                                                    isPrinting = false
                                                    netWeightData = 0
                                                    weighting1stData = 0
                                                    printInitial()
                                                }
                                            } else {
                                                print("print save 미실행")
                                                isPrinting = false
                                                netWeightData = 0
                                                weighting1stData = 0
                                                printInitial()
                                            }
                                        }
                                    }
                                )
                                .disabled(isPrint)
                                .opacity(isPrint ? 0.4 : 1.0)
                                
                                if settingViewModel.weightingMethod == 2 {
                                    SaveButton(
                                        beforeSave: {
                                            guard
                                                !twoStepLoadAxleStatus.isEmpty,
                                                !loadAxleStatus.isEmpty
                                            else { return }
                                            twoStepLoadAxleStatus[0].loadAxlesData.append(contentsOf: loadAxleStatus[0].loadAxlesData)
                                            twoStepLoadAxleStatus[0].total = twoStepLoadAxleStatus[0].total + loadAxleStatus[0].total
                                        },
                                        loadAxleStatus: $twoStepLoadAxleStatus,
                                        client: "\(selectedClient?.name ?? "N/A")",
                                        product: "\(selectedProduct?.name ?? "N/A")",
                                        vehicle: "\(selectedVehicle?.vehicle ?? "N/A")",
                                        serialNumber : "\(mainViewModel.sn)",               // 시리얼 넘버 비교 저장 필요
                                        equipmentNumber : bleManager.equipmentNumber,       // 추후 진짜 장치 고유번호 정식 번호 저장 필요
                                        weightNum : String(settingViewModel.weightingMethod),
                                        onSave: {
                                            isTwoStep = false
                                        }
                                    )
                                } else {
                                    SaveButton(
                                        beforeSave: {
                                            print("beforSave")
                                        },
                                        loadAxleStatus: $loadAxleStatus,
                                        client: "\(selectedClient?.name ?? "N/A")",
                                        product: "\(selectedProduct?.name ?? "N/A")",
                                        vehicle: "\(selectedVehicle?.vehicle ?? "N/A")",
                                        serialNumber : "\(mainViewModel.sn)",               // 시리얼 넘버 비교 저장 필요
                                        equipmentNumber : bleManager.equipmentNumber,       // 추후 진짜 장치 고유번호 정식 번호 저장 필요
                                        weightNum : String(settingViewModel.weightingMethod),
                                        onSave: {}
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
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
                               onSelectProduct: { selectedProduct = $0; goToList = false },
                               onSelectClient: { selectedClient = $0; goToList = false },
                               onSelectVehicle: { selectedVehicle = $0; goToList = false }
                    )
                }
            }.navigationDestination(isPresented: $goToData) {
                DataScreen(printViewModel: printViewModel, settingViewModel: settingViewModel)
            }.alert(item: $activeAlert) { alertType in
                Alert(
                    title: Text(""),
                    message: Text(alertType.message),
                    dismissButton: .default(
                        Text("OK"),
                        action: {
                            isAlertShowing = false
                            activeAlert = nil
                            netWeightData = 0
                            weighting1stData = 0
                            vehicleNum.removeAll()
                            printInitial()
                        }
                    )
                )
            }.onDisappear {
                activeAlert = nil
                isAlertShowing = false
//                selectedProduct = nil
//                selectedClient = nil
//                selectedVehicle = nil
//                loadAxleStatus = []
//                twoStepLoadAxleStatus = []
//                totalSumValue = 0
//                isMainSum = false
//                isTwoStep = false
//                isPrint = false
//                isSave = false
//                printResponse = ""
//                selectedListType = nil
//                isPrinting = false
//                weighting1stData = 0
//                netWeightData = 0
//                vehicleNumber = ""
//                selectNum = 0
//                enterError = ""
            }.onReceive(bleManager.$printResponse) { newValue in
                guard !newValue.isEmpty else { return }
                if !isAlertShowing {
                    isAlertShowing = true
                    activeAlert = .printResponse(newValue)
                    isPrinting = false
                }
            }.onReceive(bleManager.$isSum) { newValue in
                guard newValue else { return }
                isMainSum = newValue
            }.onReceive(bleManager.$isCancel) { newValue in
                guard newValue else {
                    print("isSum false")
                    return
                }
                okButtonAction()
                loadAxleStatus = []
                isSave = false
                isMainSum = false
                isPrint = false
                totalSumValue = 0
                weighting1stData = 0
                netWeightData = 0
                isTwoStep = false
                print("isSum true")
            }.onReceive(bleManager.$SnNumber) { newSn in
                guard newSn > 0 else { return }
                mainViewModel.saveSn(newSn)
                mainViewModel.loadSn()
            }.onReceive(bleManager.$inmotion) { newValue in
                guard newValue != 0, saveValue != newValue , newValue != 49 else { return }
                saveValue = newValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mainViewModel.handleInmotion(
                        loadAxleStatus: &loadAxleStatus,
                        left: bleManager.leftLoadAxel1 ?? 0,
                        right: bleManager.rightLoadAxel1 ?? 0
                    )
                }
            }
            
            if isPrinting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Printing...")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(dataViewModel.printingNumber) / \(settingViewModel.printOutputCount + 1)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
    }
    
    func okButtonAction() {
        loadAxleStatus = []
        isSave = false
        isMainSum = false
        isPrint = false
        totalSumValue = 0
        saveValue = 0
        bleManager.sendCancelCommand()
    }
    
    func printInitial() {
        loadAxleStatus = []
        isSave = false
        isMainSum = false
        isPrint = false
        totalSumValue = 0
        saveValue = 0
    }
}

#Preview {
    MainScreen()
}


