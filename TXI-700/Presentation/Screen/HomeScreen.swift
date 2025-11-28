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
    
    @EnvironmentObject var bleManager: BluetoothManager

    var body: some View {

        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text(homeViewModel.text)
                BLEListView(bleManager: bleManager).frame(maxWidth: 400)
                    .navigationDestination(isPresented: $bleManager.isConnected) {
                    MainScreen()
                        .environmentObject(bleManager)
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
                    DataScreen()
                }.navigationDestination(isPresented: $goToMain) {
                    MainScreen().environmentObject(bleManager)
                }
                Button("Setting")
                {
                    goToSetting = true
                }
                
                Button("DisConnect")
                {
                    bluetoothConnected = false
                    bleManager.disconnect()
                }.navigationDestination(isPresented: $goToSetting) {
                    SettingScreen()
                }
            }.padding()
            
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
        }.padding()// 상태 기반 Navigation
    }
}

#Preview {
    HomeScreen()
}

