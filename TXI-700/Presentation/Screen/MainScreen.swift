//
//  ContentView.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct MainScreen: View {
    @State private var goToSetting = false
    @State private var goToList = false
    @State private var selectedListType: ListType? = nil

    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var mainViewModel = MainViewModel()
    @ObservedObject var bleManager = BluetoothManager()

    var body: some View {
        HStack {
            CustomTopBar(title: mainViewModel.text,onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onSettings: {
                goToSetting = true
            }
                         
            )
            Spacer()

        }.navigationDestination(isPresented: $goToSetting){
            SettingScreen()
        }
        
            HStack {
                
                Button("product") {
                    selectedListType = .product
                    goToList = true
                }
                
                Button("cliant") {
                    selectedListType = .cliant
                    goToList = true
                }
                
                Button("vehicle") {
                    selectedListType = .vehicle
                    goToList = true
                }
                
            }.navigationDestination(isPresented: $goToList) {
                if let type = selectedListType {
                    ListScreen(listType: type)
                }
            }
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text(mainViewModel.text)
            }.padding()
    }
}

#Preview {
    MainScreen()
}
