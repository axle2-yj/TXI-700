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
    @State private var showAlert = false
    @State private var showUnapprovedModelAlert = false
    @State private var activeAlert: ActiveHomeAlert?
    
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    @StateObject var printViewModel = PrintFormSettingViewModel()
    
    @EnvironmentObject var bleManager: BluetoothManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var oppositionTint: Color {
        colorScheme == .dark ? .black : .white
    }
    
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
                    .foregroundColor(tint)
                
                if bluetoothConnected {
                    Button("Setting") {
                        goToSetting = true
                    }.frame(maxWidth: .infinity)
                        .environmentObject(languageManager)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(tint)
                    
                    Button("DisConnect") {
                        bluetoothConnected = false
                        bleManager.disconnect()
                    }.navigationDestination(isPresented: $goToSetting) {
                        SettingScreen(viewModel: settingViewModel, printViewModel: printViewModel)
                    }.frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(tint)
                }
                Button("End") {
                    showAlert = true
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .foregroundColor(tint)
            }.onReceive(bleManager.$rfMassage) { value in
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
                        dismissButton: .default(Text("Confirmation"))
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
                .background(Color.clear) // 투명 배경
                .ignoresSafeArea()
                .cornerRadius(12)
            }
            if showUnapprovedModelAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showUnapprovedModelAlert = false
                    }
                
                VStack(spacing: 20) {
                    Text("UnapprovedModel".localized(languageManager.selectedLanguage))
                        .font(.headline)
                    
                    HStack {
                        Button("Confirmation".localized(languageManager.selectedLanguage)) {
                            showUnapprovedModelAlert = false
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(tint)
                    }
                }
                .frame(maxWidth: 250, maxHeight: 150)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(oppositionTint)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            if showAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAlert = false
                    }
                
                VStack(spacing: 20) {
                    Text("endProcess".localized(languageManager.selectedLanguage))
                        .font(.headline)
                    if bleManager.isDisconnected {
                        Button("AppEnd".localized(languageManager.selectedLanguage)) {
                            showAlert = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                            }
                            bleManager.disconnect()
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(tint)
                    } else {
                        HStack {
                            Button("AllEnd".localized(languageManager.selectedLanguage)) {
                                showAlert = false
                                bleManager.sendCommand(.btp, log: "Power Off Send")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                }
                            }.frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(tint)
                            
                            Button("AppEnd".localized(languageManager.selectedLanguage)) {
                                showAlert = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                }
                                bleManager.disconnect()
                            }.frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .foregroundColor(tint)
                        }
                    }
                }
                .frame(maxWidth: 250, maxHeight: 150)
                .padding(.horizontal, 20)
                .background(oppositionTint)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }.onAppear {
            homeViewModel.loadDeviceMac()
            homeViewModel.loadAutoConnectState()
            homeViewModel.setBleManager(bleManager)
            if homeViewModel.autoConnectEnabled && !bluetoothConnected{
                homeViewModel.startAutoConnect()
            }
        }
        .onDisappear {
            homeViewModel.stopAutoConnect()
        }
        .onReceive(bleManager.$isDisconnected) { disconnected in
            if disconnected {
                bluetoothConnected = false
            }
        }.onReceive(bleManager.$isUnapprovedModel) { unapprovedModel in
            print("unapprovedModel : \(unapprovedModel)")
            if unapprovedModel {
                bluetoothConnected = false
                bleManager.isUnapprovedModel = false
                homeViewModel.saveDeviceMac("")
                showUnapprovedModelAlert = true
            }
        }
        
    }
}

#Preview {
    HomeScreen()
}

