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

    var body: some View {
        VStack {
            // 권한 안내
            if bleManager.bluetoothPermissionStatus == .denied || bleManager.locationPermissionStatus == .denied {
                VStack(spacing: 10) {
                    Text("블루투스 또는 위치 권한이 필요합니다.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Button("설정으로 이동") {
                        DispatchQueue.main.async {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
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
                    Button(
                        action: {
                        if bleManager.isScanning {
                            bleManager.stopScan()
                            print("BLE 스캔 중지")
                        } else {
                            bleManager.startScan()
                            print("BLE 스캔 시작")
                        }
                    }) {
                        Text(bleManager.isScanning ? "Stop Scan" : "Start Scan")
                            .padding()
                            .background(bleManager.isScanning ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    List(bleManager.devices) { device in
                        Button(action: {
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
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .opacity(0)  // 체크 표시 안 보임
                                }
                            }
                            .padding(4)
                        }
                    }
                    
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

