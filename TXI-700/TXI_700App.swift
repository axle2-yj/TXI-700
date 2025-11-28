//
//  TXI_700App.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import SwiftUI

@main
struct TXI_700App: App {
    @StateObject var bleManager = BluetoothManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeScreen().environmentObject(bleManager).onAppear{
                }
            }
        }
    }
}
