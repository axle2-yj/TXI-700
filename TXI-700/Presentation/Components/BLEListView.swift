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
                    HStack {
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

                        Toggle("Auto", isOn: $homeViewModel.autoConnectEnabled)
                            .padding(.horizontal)
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
        }
    }
}

//struct BLEListView: View {
//    @ObservedObject var bleManager: BluetoothManager
//    @ObservedObject var homeViewModel = HomeViewModel()
//
//    @Binding var autoConnectEnabled: Bool
//    @Binding var savedMAC: String?
//    
//
//    var body: some View {
//        VStack {
//            // 권한 안내
//            if bleManager.bluetoothPermissionStatus == .denied || bleManager.locationPermissionStatus == .denied {
//                VStack(spacing: 10) {
//                    Text("\(NSLocalizedString("AuthorizationWarning", comment: ""))")
//                        .font(.headline)
//                        .multilineTextAlignment(.center)
//                    
//                    Button("\(NSLocalizedString("MoveSetting", comment: ""))") {
//                        DispatchQueue.main.async {
//                            if let url = URL(string: UIApplication.openSettingsURLString) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//                .padding()
//            } else {
//                VStack {
//                    HStack {
//                        Button(
//                            action: {
//                            if bleManager.isScanning {
//                                bleManager.stopScan()
//                                print("BLE 스캔 중지")
//                            } else {
//                                bleManager.startScan()
//                                print("BLE 스캔 시작")
//                            }
//                        }) {
//                            Text(bleManager.isScanning ? "Stop Scan" : "Start Scan")
//                                .padding()
//                                .background(bleManager.isScanning ? Color.red : Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                        }
//                        .padding()
//                        
//                        Toggle("Auto", isOn: $homeViewModel.autoConnectEnabled)
//                            .padding()
//                            .onChange(of: homeViewModel.autoConnectEnabled) { enabled, _ in
//                                homeViewModel.setAutoConnectState(enabled)
//                            }
//                    }
//                    
//
//                    List(bleManager.devices) { device in
//                        Button(action: {
//                            homeViewModel.saveDeviceMac(device.mac)
//                            bleManager.connect(to: device)
//                            bleManager.stopScan()
//                        }) {
//                            HStack {
//                                Text(device.name)
//                                    .font(.headline)
//                                Spacer()
//                                if bleManager.connectedPeripheral?.identifier == device.id {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                } else {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .opacity(0)  // 체크 표시 안 보임
//                                }
//                            }
//                            .padding(4)
//                        }
//                    }
//                    
//                    if bleManager.isConnected {
//                        VStack {
//                            Text("Connected to: \(bleManager.connectedPeripheral?.name ?? "Unknown")")
//                                .font(.subheadline)
//                                .padding(.top)
//                            Text("Received Data: \(bleManager.receivedText)")
//                                .font(.body)
//                                .padding(.top, 2)
//                        }
//                        .padding()
//                    }
//                    
//                    Spacer()
//                }
//            }
//        }
//    }
//}
//
