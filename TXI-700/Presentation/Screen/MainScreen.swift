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
    @StateObject private var keyboard = KeyboardObserver()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bleManager: BluetoothManager
    @EnvironmentObject var languageManager: LanguageManager
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var bottom: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        ZStack {
            let axleWeightsDict: [Int: (left: Int, right: Int, total: Int, leftBatteryLevel: Int, rightBatteryLevel: Int)] = Dictionary(
                uniqueKeysWithValues: (1...4).map { i in
                    let axle = bleManager.axles[i] ?? AxleState.empty(axle: i)
                    return (i, (axle.leftWeight ?? 0, axle.rightWeight ?? 0, axle.totalWeight, axle.leftBatteryLevel ?? 0, axle.rightBatteryLevel ?? 0))
                }
            )
            let left1 = axleWeightsDict[1]?.left ?? 0
            let right1 = axleWeightsDict[1]?.right ?? 0
            let left2 = axleWeightsDict[2]?.left ?? 0
            let right2 = axleWeightsDict[2]?.right ?? 0
            let left3 = axleWeightsDict[3]?.left ?? 0
            let right3 = axleWeightsDict[3]?.right ?? 0
            let left4 = axleWeightsDict[4]?.left ?? 0
            let right4 = axleWeightsDict[4]?.right ?? 0
            
            let total1 = axleWeightsDict[1]?.total ?? 0
            
            let left1Bat = axleWeightsDict[1]?.leftBatteryLevel ?? 0
            let right1Bat = axleWeightsDict[1]?.rightBatteryLevel ?? 0
            let indicatorBat = bleManager.indicatorBatteryLevel ?? 0
            
            VStack(spacing: 3) {
                ClockView(currentTime: $clockManager.currentTime)
                ScrollView {
                    VStack(spacing: 3) {
                        if settingViewModel.weightingMethod == 3 {
                            BalanceModeCell(
                                axles: balanceAxles,
                                indicatorBattery: indicatorBat,
                            )
                        } else {
                            
                            BatteryLevelLoadAxleWeightView(
                                level: left1Bat,
                                divice: "LEFT:",
                                axleWight: String(left1))
                            BatteryLevelLoadAxleWeightView(
                                level: right1Bat,
                                divice: "RIGHT:",
                                axleWight: String(right1))
                            BatteryLevelLoadAxleWeightView(
                                level: bleManager.indicatorBatteryLevel ?? 0,
                                divice: "AXLE:",
                                axleWight: String(total1))
                        }
                    }
                }.scrollDisabled(keyboard.keyboardHeight == 0)
                
                let noWidth: CGFloat = 35
                VStack(alignment: .leading, spacing: 5) {
                    if settingViewModel.weightingMethod != 3 {
                        HStack {
                            Text("No")
                                .frame(width: noWidth, alignment: .leading)
                            TableColumn(alignment: .center) {
                                Text("LEFT")
                            }
                            
                            TableColumn(alignment: .center) {
                                Text("RIGHT")
                            }
                            
                            TableColumn(alignment: .center) {
                                Text("AXLE")
                            }
                        }
                        .font(.system(size: 25))
                        .background(Color.gray.opacity(0.1))
                        .padding(.vertical, 2)
                        
                        ScrollView {
                            if !loadAxleStatus.isEmpty {
                                ForEach(loadAxleStatus) { loadAxle in
                                    let rowCount = (loadAxle.loadAxlesData.count + 1) / 2
                                    ForEach(0..<rowCount, id: \.self) { rowIndex in
                                        let firstIndex = rowIndex * 2
                                        let secondIndex = firstIndex + 1
                                        
                                        let firstValue = loadAxle.loadAxlesData.indices.contains(firstIndex) ? loadAxle.loadAxlesData[firstIndex] : 0
                                        let secondValue = loadAxle.loadAxlesData.indices.contains(secondIndex) ? loadAxle.loadAxlesData[secondIndex] : 0
                                        HStack {
                                            Text("\(loadAxle.id + rowIndex)")
                                                .frame(width: noWidth, alignment: .leading)
                                            TableColumn(alignment: .trailing) {
                                                MainWeightText(value: firstValue)
                                            }
                                            TableColumn(alignment: .trailing) {
                                                MainWeightText(value: secondValue)
                                            }
                                            
                                            TableColumn(alignment: .trailing) {
                                                MainWeightText(value: firstValue + secondValue)
                                            }
                                        }
                                        .lineLimit(1)
                                        .padding(.vertical, 5)
                                        Divider()
                                        
                                    }
                                }
                            }
                        }
                    } else {
                        GeometryReader { geo in
                            ScrollView {
                                if settingViewModel.balanceAxisNuberCount == 0 {
                                    WeightBalanceOverAxleView(
                                        axles: [
                                            Axle(left: CGFloat(left1), right: CGFloat(right1)),
                                            Axle(left: CGFloat(left2), right: CGFloat(right2)),
                                        ],
                                        isEdgeTotals: settingViewModel.balanceWeight,
                                        viewModel: settingViewModel
                                    )
                                    .frame(maxHeight: geo.size.height - 25)
                                } else if settingViewModel.balanceAxisNuberCount == 1 {
                                    WeightBalanceOverAxleView(
                                        axles: [
                                            Axle(left: CGFloat(left1), right: CGFloat(right1)),
                                            Axle(left: CGFloat(left2), right: CGFloat(right2)),
                                            Axle(left: CGFloat(left3), right: CGFloat(right3))
                                        ],
                                        isEdgeTotals: settingViewModel.balanceWeight,
                                        viewModel: settingViewModel
                                    )
                                    .frame(maxHeight: geo.size.height - 25)
                                } else {
                                    WeightBalanceOverAxleView(
                                        axles: [
                                            Axle(left: CGFloat(left1), right: CGFloat(right1)),
                                            Axle(left: CGFloat(left2), right: CGFloat(right2)),
                                            Axle(left: CGFloat(left3), right: CGFloat(right3)),
                                            Axle(left: CGFloat(left4), right: CGFloat(right4))
                                        ],
                                        isEdgeTotals: settingViewModel.balanceWeight,
                                        viewModel: settingViewModel
                                    )
                                    .frame(maxHeight: geo.size.height - 25)
                                }
                            }
                        }.scrollDisabled(keyboard.keyboardHeight == 0)
                        let weightingMethodInt = settingViewModel.weightingMethod
                        let balanceCellNum = settingViewModel.balanceAxisNuberCount
                        let vehicle = String(vehicleNum).isEmpty ? "N/A" : String(vehicleNum)
                        let client = String(clientViewModel.selectedClient?.name ?? "N/A")
                        let product = String(productViewModel.selectedProduct?.name ?? "N/A")
                        let leftAxles  = [left1, left2, left3, left4]
                        let rightAxles = [right1, right2, right3, right4]
                        
                        let lines: [String] = {
                            PrintLineBuilder.buildBalanceLines(
                                axleState: bleManager.axles,
                                timeStamp: Date(),
                                client : client,
                                vehicle : vehicle,
                                serialNumber: String(mainViewModel.sn),
                                printViewModel: printViewModel
                            )
                        }()
                        
                        HStack {
                            Button("Car.no") {
                                selectedListType = .vehicle
                                goToList = true
                            }.padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(tint)
                            CustomPlaceholderTextField(
                                placeholder: "VehicleNum".localized(languageManager.selectedLanguage),
                                text: $vehicleNum
                            ).onReceive(vehicleViewModel.$selectedVehicle) { newValue in
                                guard newValue != nil else { return }
                                vehicleNum = newValue?.vehicle ?? ""
                                weighting1stData = Int(newValue?.weight ?? 0)
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
                                    if balanceCellNum == 0 {
                                        
                                        for i in 0..<2 {
                                            mainViewModel.handleLoadAxleState(
                                                loadAxleStatus: &loadAxleStatus,
                                                left: leftAxles[i],
                                                right: rightAxles[i]
                                            )
                                        }
                                    } else {
                                        for i in 0..<3 {
                                            mainViewModel.handleLoadAxleState(
                                                loadAxleStatus: &loadAxleStatus,
                                                left: leftAxles[i],
                                                right: rightAxles[i]
                                            )
                                        }
                                    }
                                },
                                offPrint: {
                                    let vehicle = String(vehicleViewModel.selectedVehicle?.vehicle ?? "N/A")
                                    if weightingMethodInt == 3 && !loadAxleStatus.isEmpty {
                                        LoadAxleSaveService.printSaveData(
                                            serialNumber: String(mainViewModel.sn),
                                            equipmentNumber: String(bleManager.equipmentNumber),
                                            client: "\(client)",
                                            product: "\(product)",
                                            vehicle: "\(vehicle)",
                                            weightNum: String(weightingMethodInt),
                                            loadAxleStatus: loadAxleStatus
                                        ) {
                                            isPrinting = false
                                            printInitial()
                                        }
                                    }
                                }).frame(height: 30)
                        }.safeAreaPadding(
                            .bottom,
                            settingViewModel.weightingMethod == 3
                            ? keyboard.keyboardHeight - 300
                            : 0
                        )
                        .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight - 300)
                    }
                }.padding(.horizontal)
            }
            .safeAreaInset(edge: .top) {
                CustomMainTopBar(title: mainViewModel.text,onBack: {
                    presentationMode.wrappedValue.dismiss()
                }, onSettings: {
                    goToSetting = true
                }, viewModel: settingViewModel)
                .onReceive(bleManager.$modeChangeInt) { newValue in
                    settingViewModel.saveModeChange(newValue)
                    settingViewModel.loadModeChange(colorScheme == .dark)
                }.onAppear {
                    DispatchQueue.main.async {
                        mainViewModel.loadProduct()
                        mainViewModel.loadClient()
                        mainViewModel.startTimer(bleManager: bleManager)
                    }
                    mainViewModel.loadSn()
                    settingViewModel.loadLanguage()
                    settingViewModel.loadWeightingMethod()
                    settingViewModel.loadModeChange(colorScheme == .dark)
                    settingViewModel.loadProductCkeck()
                    settingViewModel.loadClientCkeck()
                    settingViewModel.loadPrintOutputCountSetting()
                    settingViewModel.loadBalanceAxisNumberSetting()
                    settingViewModel.loadBalanceWeghtSetting()
                    settingViewModel.loadDangerousNumberSetting()
                    settingViewModel.loadCautionNumberSetting()
                    settingViewModel.loadSafetyNumberSetting()
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
                            }.padding(.horizontal, 5)
                                .font(Font.system(size: 20, weight: .bold, design: .default))
                            
                            HStack {
                                if settingViewModel.weightingMethod == 2 {
                                    Text("1stWeight")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(Font.system(size: 20, weight: .bold, design: .default))
                                    Text(" : ")
                                        .font(Font.system(size: 15, weight: .bold, design: .default))
                                    Text("\(weighting1stData)")
                                        .lineLimit(1)
                                        .font(Font.system(size: 20, weight: .bold, design: .default))
                                    Text("kg")
                                        .font(Font.system(size: 15, weight: .bold, design: .default))
                                    Spacer()
                                    Text("NetWeight").lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(Font.system(size: 20, weight: .bold, design: .default))
                                    Text(String(netWeightData)).lineLimit(1)
                                        .font(Font.system(size: 20, weight: .bold, design: .default))
                                    Text("kg")
                                        .font(Font.system(size: 15, weight: .bold, design: .default))
                                }
                            }.padding(.horizontal, 5)
                                
                        }
                        let isButtonEnabled = (settingViewModel.weightingMethod != 0 || !vehicleNum.isEmpty) && !isTwoStep
                        HStack {
                            Button("Car.no") {
                                selectedListType = .vehicle
                                goToList = true
                            }.padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(tint)
                            
                            CustomPlaceholderTextField(
                                placeholder: "VehicleNum".localized(languageManager.selectedLanguage),
                                text: $vehicleNum
                            ).onReceive(vehicleViewModel.$selectedVehicle) { newValue in
                                guard newValue != nil else { return }
                                vehicleNum = newValue?.vehicle ?? ""
                                weighting1stData = Int(newValue?.weight ?? 0)
                            }
                            
                            
                            if settingViewModel.weightingMethod != 1 {
                                Button(settingViewModel.weightingMethod != 2 ? "Send" : "1stWeight") {
                                    if settingViewModel.weightingMethod == 2 {
                                        guard !loadAxleStatus.isEmpty else { return }
                                        let total = loadAxleStatus.reduce(0) { $0 + $1.total }
                                        loadAxleStatus[0].loadAxlesData = [total]
                                        twoStepLoadAxleStatus = loadAxleStatus
                                        weighting1stData = loadAxleStatus.reduce(0) { $0 + $1.total }
                                        isTwoStep = true
                                        isMainSum = false
                                        okButtonAction()
                                    } else if settingViewModel.weightingMethod == 0{
                                        bleManager.sendCommand(.btc(vehicleNum), log: "Vehicle Save Send")
                                    }
                                }.padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(tint)
                                    .disabled(!isButtonEnabled)
                                    .opacity(isButtonEnabled ? 1.0 : 0.4)
                            } else {
                                Button("Save") {
                                    vehicleViewModel.save(vehicleNum: vehicleNum)
                                }.padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(tint)
                                    .disabled(!isButtonEnabled)
                                    .opacity(isButtonEnabled ? 1.0 : 0.4)
                                    .onReceive(vehicleViewModel.$saveSuccessMessage) { message in
                                        guard message != nil else { return }
                                        activeAlert = .saveSuccess(message ?? "")
                                    }.onReceive(vehicleViewModel.$saveFailedMessage) { message in
                                        guard message != nil else { return }
                                        activeAlert = .saveError((message!.localized(languageManager.selectedLanguage)))
                                    }
                            }
                        }
                        
                        HStack {
                            if settingViewModel.checkedProduct {
                                Button("\(productViewModel.selectedProduct?.name ?? mainViewModel.saveProduct ?? "ITEM <<")") {
                                    selectedListType = .product
                                    goToList = true
                                }.frame(maxWidth: .infinity) // 화면 절반 차지
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(tint)
                            }
                            
                            if settingViewModel.checkedClient {
                                Button("\(clientViewModel.selectedClient?.name ?? mainViewModel.saveClient ?? "CLIENT <<")") {
                                    selectedListType = .client
                                    goToList = true
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(tint)
                            }
                        }
                        
                        HStack {
                            ZeroButton()
                            Button("DATA") {
                                goToData = true
                                bleManager.sendCommand(.bdc, log: "SaveData Call")
                            }.frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(tint)
                            if isMainSum {
                                Button("CANCEL") {
                                    okButtonAction()
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(tint)
                            }
                        }
                        
                        HStack {
                            if !isMainSum {
                                let isSumEnabled = (loadAxleStatus.last?.loadAxlesData.indices.contains(1) ?? false) && (loadAxleStatus.last?.loadAxlesData[1] ?? 0) != 0
                                EnterButton(
                                    viewModel: settingViewModel,
                                    loadAxleStatus: $loadAxleStatus,
                                    onEnter: {
                                        if settingViewModel.weightingMethod == 2 {
                                            totalSumValue = loadAxleStatus.reduce(0) { $0 + $1.total }
                                            netWeightData = totalSumValue - weighting1stData
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
                                let vehicle = String(vehicleViewModel.selectedVehicle?.vehicle ?? "N/A")
                                let product = String(productViewModel.selectedProduct?.name ?? "N/A")
                                let client = String(clientViewModel.selectedClient?.name ?? "N/A")
                                
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
                                        item: product,
                                        client : client,
                                        vehicle : vehicle,
                                        serialNumber: String(mainViewModel.sn),
                                        selectedType: weightingMethodInt
                                    )
                                } else {
                                    PrintLineBuilder.buildSecond(
                                        loadAxleItem: loadAxleStatus,
                                        dataViewModel: dataViewModel,
                                        printViewModel: printViewModel,
                                        timeStamp: Date(),
                                        item: product,
                                        client : client,
                                        vehicle : vehicle,
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
                                            bleManager.sendCommand(.btc(vehicleNum), log: "Vehicle Save Send")
                                        }
                                    },
                                    offPrint: {
                                        let vehicle = String(vehicleViewModel.selectedVehicle?.vehicle ?? "N/A")
                                        if weightingMethodInt == 2 {
                                            twoStepLoadAxleStatus[0].loadAxlesData.append(loadAxleStatus[0].total)
                                            twoStepLoadAxleStatus[0].total = twoStepLoadAxleStatus[0].total + loadAxleStatus[0].total
                                            print(twoStepLoadAxleStatus)
                                            if !isSave {
                                                LoadAxleSaveService.printSaveData(
                                                    serialNumber: String(mainViewModel.sn),
                                                    equipmentNumber: String(bleManager.equipmentNumber),
                                                    client: "\(client)",
                                                    product: "\(product)",
                                                    vehicle: "\(vehicle)",
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
                                                    client: "\(client)",
                                                    product: "\(product)",
                                                    vehicle: "\(vehicle)",
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
                                        client: "\(client)",
                                        product: "\(product)",
                                        vehicle: "\(vehicle)",
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
                                        client: "\(client)",
                                        product: "\(product)",
                                        vehicle: "\(vehicle)",
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
                .background(bottom)
            }
            .onTapGesture {
                hideKeyboard()
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
                               onSelectProduct: { goToList = false },
                               onSelectClient: { goToList = false },
                               onSelectVehicle: { goToList = false }
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
                            switch alertType {
                            case .saveSuccess:
                                break
                            case .saveError:
                                break
                            default:
                                isAlertShowing = false
                                activeAlert = nil
                                netWeightData = 0
                                weighting1stData = 0
                                vehicleNum.removeAll()
                                printInitial()
                            }
                        }
                    )
                )
            }.onDisappear {
                activeAlert = nil
                isAlertShowing = false
            }.onReceive(bleManager.$printResponse) { newValue in
                guard !newValue.isEmpty else { return }
                if !isAlertShowing {
                    isAlertShowing = true
                    activeAlert = .printResponse(newValue)
                    isPrinting = false
                }
            }
//            .onReceive(bleManager.$isSum) { newValue in
//                guard newValue else { return }
//                isMainSum = newValue
//            }
//            .onReceive(bleManager.$isCancel) { newValue in
//                guard newValue else { return }
//                okButtonAction()
//                loadAxleStatus = []
//                isSave = false
//                isMainSum = false
//                isPrint = false
//                totalSumValue = 0
//                if !isTwoStep {
//                    weighting1stData = 0
//                }
//                netWeightData = 0
//                isTwoStep = false
//            }
            .onReceive(bleManager.$SnNumber) { newSn in
                guard newSn > 0 else { return }
                mainViewModel.saveSn(newSn)
                mainViewModel.loadSn()
            }.onReceive(bleManager.$inmotion) { newValue in
                guard newValue != 0, saveValue != newValue , newValue != 49 else { return }
                saveValue = newValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mainViewModel.handleInmotion(
                        loadAxleStatus: &loadAxleStatus,
                        left: left1,
                        right: right1
                    )
                }
            }
            .onChange(of: bleManager.indicatorState) { state, _ in
                switch state {
                case IndicatorState.sum:
                    if isMainSum {
                        isMainSum = false
                        print("print")
                    } else {
                        isMainSum = true
                        print("sum")
                    }
                case IndicatorState.enter:
                    if isMainSum {
                        print("cancel")
                        okButtonAction()
                        loadAxleStatus = []
                        isSave = false
                        isMainSum = false
                        isPrint = false
                        totalSumValue = 0
                        if !isTwoStep {
                            weighting1stData = 0
                        }
                        netWeightData = 0
                        isTwoStep = false
                        settingViewModel.isSum = false
                    }
                default:
                    break
                }
                bleManager.indicatorState = .idle
            }
            .onChange(of: goToSetting) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
            .onChange(of: goToList) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
            .onChange(of: goToData) { _, newValue in
                if newValue {
                    hideKeyboard()
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
    
    var content: some View {
        VStack(spacing: 3) {
            ClockView(currentTime: $clockManager.currentTime)
        }
    }
    
    func okButtonAction() {
        loadAxleStatus = []
        isSave = false
        isMainSum = false
        isPrint = false
        totalSumValue = 0
        saveValue = 0
        bleManager.sendCommand(.bte, log: "Cancel")
    }
    
    func printInitial() {
        loadAxleStatus = []
        isSave = false
        isMainSum = false
        isPrint = false
        totalSumValue = 0
        saveValue = 0
    }
    
    private var balanceAxles: [BalanceCellData] {
        let axleWeightsDict: [Int: (left: Int, right: Int, total: Int, leftBatteryLevel: Int, rightBatteryLevel: Int)] = Dictionary(
            uniqueKeysWithValues: (1...4).map { i in
                let axle = bleManager.axles[i] ?? AxleState.empty(axle: i)
                return (i, (axle.leftWeight ?? 0, axle.rightWeight ?? 0, axle.totalWeight, axle.leftBatteryLevel ?? 0, axle.rightBatteryLevel ?? 0))
            }
        )
        let left1 = axleWeightsDict[1]?.left ?? 0
        let right1 = axleWeightsDict[1]?.right ?? 0
        let left2 = axleWeightsDict[2]?.left ?? 0
        let right2 = axleWeightsDict[2]?.right ?? 0
        let left3 = axleWeightsDict[3]?.left ?? 0
        let right3 = axleWeightsDict[3]?.right ?? 0
        let left4 = axleWeightsDict[4]?.left ?? 0
        let right4 = axleWeightsDict[4]?.right ?? 0
        
        let left1Bat = axleWeightsDict[1]?.leftBatteryLevel ?? 0
        let right1Bat = axleWeightsDict[1]?.rightBatteryLevel ?? 0
        let left2Bat = axleWeightsDict[2]?.leftBatteryLevel ?? 0
        let right2Bat = axleWeightsDict[2]?.rightBatteryLevel ?? 0
        let left3Bat = axleWeightsDict[3]?.leftBatteryLevel ?? 0
        let right3Bat = axleWeightsDict[3]?.rightBatteryLevel ?? 0
        let left4Bat = axleWeightsDict[4]?.leftBatteryLevel ?? 0
        let right4Bat = axleWeightsDict[4]?.rightBatteryLevel ?? 0
        
        var result: [BalanceCellData] = [
            BalanceCellData(
                leftWeight: left1,
                rightWeight: right1,
                leftBattery: left1Bat,
                rightBattery: right1Bat
            ),
            BalanceCellData(
                leftWeight: left2,
                rightWeight: right2,
                leftBattery: left2Bat,
                rightBattery: right2Bat
            )
        ]
        
        if settingViewModel.balanceAxisNuberCount == 1 {
            result.append(
                BalanceCellData(
                    leftWeight: left3,
                    rightWeight: right3,
                    leftBattery: left3Bat,
                    rightBattery: right3Bat
                )
            )
        }
        
        if settingViewModel.balanceAxisNuberCount == 2 {
            result.append(
                BalanceCellData(
                    leftWeight: left3,
                    rightWeight: right3,
                    leftBattery: left3Bat,
                    rightBattery: right3Bat
                )
            )
            result.append(
                BalanceCellData(
                    leftWeight: left4,
                    rightWeight: right4,
                    leftBattery: left4Bat,
                    rightBattery: right4Bat
                )
            )
        }
        return result
    }
    
}


#Preview {
    MainScreen()
}


