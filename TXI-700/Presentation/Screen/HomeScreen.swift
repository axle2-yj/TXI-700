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

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text(homeViewModel.text)
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
                    DataScreen(printViewModel: printViewModel)
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
            }.padding()
                .onAppear{
                    if homeViewModel.autoConnectEnabled {
                        bleManager.savedMac = homeViewModel.savedMAC
                    }
                }
            
            if bleManager.isConnecting {
                Color.black.opacity(0.4).ignoresSafeArea()
                ZStack {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white)) // 색상도 변경 가능
                            .scaleEffect(2.0) // 크기 2배
                        Text("Connecting...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 전체 화면 채우기
                .background(Color.clear) // 투명 배경
                .ignoresSafeArea()
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

