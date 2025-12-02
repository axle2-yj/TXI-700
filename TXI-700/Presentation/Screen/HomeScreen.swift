//
//  HomeScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct HomeScreen: View {
    @State private var goToData = false
    @State private var goToMain = false
    @State private var goToSetting = false
    @State private var bluetoothConnected = false

    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    @StateObject var printViewModel = PrintFormSettingViewModel()
    
    @EnvironmentObject var bleManager: BluetoothManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var activeAlert: ActiveHomeAlert?

    var body: some View {
        ZStack {
            VStack {
                Text(homeViewModel.text).font(.title)
                
                Image("TXI_700")
                    .resizable()
                    .frame(width: 300, height: 300)
                    
                BLEListView(bleManager: bleManager,
                            homeViewModel: homeViewModel,
                            autoConnectEnabled: $homeViewModel.autoConnectEnabled,
                            savedMAC: $homeViewModel.savedMAC
                ).frame(maxWidth: 400)
                    .navigationDestination(isPresented: $bleManager.isConnected) {
                        MainScreen()
                            .environmentObject(bleManager)
                            .environmentObject(languageManager)
                            .onAppear {
                                bluetoothConnected = true
                                goToMain = false
                                bleManager.isConnecting = false
                                bleManager.devices.removeAll()
                            }
                    }
                Button(bluetoothConnected ? "Start" : "Data") {
                    if bluetoothConnected {
                        goToMain = true
                        goToData = false
                    } else {
                        goToData = true
                        goToMain = false
                    }
                }.navigationDestination(isPresented: $goToData) {
                    DataScreen(printViewModel: printViewModel, settingViewModel: settingViewModel)
                }.navigationDestination(isPresented: $goToMain) {
                    MainScreen().environmentObject(bleManager)
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .foregroundColor(.black)
                
                if bluetoothConnected {
                    Button("Setting")
                    {
                        goToSetting = true
                    }.frame(maxWidth: .infinity)
                        .environmentObject(languageManager)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.black)
                    
                    Button("DisConnect")
                    {
                        bluetoothConnected = false
                        bleManager.disconnect()
                    }.navigationDestination(isPresented: $goToSetting) {
                        SettingScreen(viewModel: settingViewModel, printViewModel: printViewModel)
                    }.frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.black)
                }
            }.onReceive(bleManager.$rf) { value in
                if value.isEmpty { return }
                switch value {
                case "01":
                    activeAlert = .error("error1".localized(languageManager.selectedLanguage))
                case "02":
                    activeAlert = .error("error2".localized(languageManager.selectedLanguage))
                default :
                    break
                }
            }.padding()
                .onAppear{
                    if homeViewModel.autoConnectEnabled {
                        bleManager.savedMac = homeViewModel.savedMAC
                    }
                }.alert(item: $activeAlert) { alert in
                    Alert(
                        title: Text(""),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            if bleManager.isConnecting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        Text("Connecting...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                .padding(24)
                .background(Color.clear) // 투명 배경
                .ignoresSafeArea()
                .cornerRadius(12)
            }
        }.padding()
            .onAppear {
                homeViewModel.loadDeviceMac()
                homeViewModel.loadAutoConnectState()
                homeViewModel.setBleManager(bleManager)
                if homeViewModel.autoConnectEnabled {
                    homeViewModel.startAutoConnect()
                }
            }
            .onDisappear {
                homeViewModel.stopAutoConnect()
            }
    }
}

#Preview {
    HomeScreen()
}

