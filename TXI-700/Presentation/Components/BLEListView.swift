//
//  BLEListView.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import SwiftUI
import CoreBluetooth
import Foundation

struct BLEListView: View {
    @ObservedObject var bleManager: BluetoothManager
    @ObservedObject var homeViewModel: HomeViewModel
    
    @Binding var autoConnectEnabled: Bool
    @Binding var savedMAC: String?
    @State private var optionAuto = false
    
    var body: some View {
        VStack {
            // MARK: - 권한 안내
            if bleManager.bluetoothPermissionStatus == .denied ||
                bleManager.locationPermissionStatus == .denied {
                
                VStack(spacing: 10) {
                    Text("AuthorizationWarning")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Button("MoveSetting") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
            } else {
                
                VStack {
                    // MARK: - 스캔 버튼 + Auto 토글
                    
                    HStack(spacing: 20) {
                        Button(
                            action: {
                                if bleManager.isScanning {
                                    bleManager.stopScan()
                                    bleManager.isSelfScanning = false
                                    print("BLE 스캔 중지")
                                } else {
                                    bleManager.startScan()
                                    bleManager.isSelfScanning = true
                                    print("BLE 스캔 시작")
                                }
                            }) {
                                Text(bleManager.isScanning ? "Stop Scan" : "Start Scan")
                                    .padding()
                                    .background(bleManager.isScanning ? Color.red : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.leading)
                        
                        CheckBoxAuto(isChecked: $optionAuto,
                                     viewModel: homeViewModel,
                                     label: "Auto")
                        .onChange(of: homeViewModel.autoConnectEnabled) { enabled, _ in
                            if enabled {
                                bleManager.stopScan()
                            }
                            homeViewModel.setAutoConnectState(enabled)
                        }
                    }
                    
                    // MARK: - 리스트 표시 조건
                    if bleManager.isSelfScanning {
                        
                        List(bleManager.devices) { device in
                            Button(action: {
                                homeViewModel.saveDeviceMac(device.mac)
                                bleManager.connect(to: device)
                                bleManager.stopScan()
                            }) {
                                HStack {
                                    Text(device.name)
                                        .font(.headline)
                                    Spacer()
                                    if bleManager.connectedPeripheral?.identifier == device.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(4)
                            }
                        }
                    }
                    
                    // MARK: - 연결 정보
                    if bleManager.isConnected {
                        VStack {
                            Text("Connected to: \(bleManager.connectedPeripheral?.name ?? "Unknown")")
                                .font(.subheadline)
                                .padding(.top)
                            Text("Received Data: \(bleManager.receivedText)")
                                .font(.body)
                                .padding(.top, 2)
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
        }.onAppear {
            optionAuto = homeViewModel.autoConnectEnabled
        }
    }
}
