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
                Button(bluetoothConnected ? "Start" : "Data") {
                    if goToMainBinding.wrappedValue {
                        goToData = true
                        goToMain = false
                    } else {
                        goToMain = true
                        goToData = false
                    }
                }
                
                Button("Setting")
                {
                    goToSetting = true
                }
                
                Button("DisConnect")
                {
                    bluetoothConnected = false
                    bleManager.disconnect()
                }
            }.padding()
            
            if bleManager.isConnecting {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Connecting...")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }
        }.padding()// 상태 기반 Navigation
            .navigationDestination(isPresented: $goToData) {
                DataScreen()
            }
            .navigationDestination(isPresented: $goToSetting) {
                SettingScreen()
            }
            .navigationDestination(isPresented: $bleManager.isConnected) {
                MainScreen()
                    .environmentObject(bleManager)
                    .onAppear {
                        bluetoothConnected = true
                        goToMain = false
                        bleManager.isConnecting = false
                        bleManager.devices.removeAll()
                        print("확인용 \(goToMainBinding.wrappedValue)")
                    }
            }
    }
    
    var goToMainBinding: Binding<Bool> {
            Binding(
                get: { bleManager.isConnected || goToMain },
                set: { newValue in
                    if !newValue {
                        goToMain = false
                    }
                }
            )
        }
}

#Preview {
    HomeScreen()
}

