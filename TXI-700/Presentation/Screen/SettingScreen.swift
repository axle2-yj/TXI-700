//
//  SettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct SettingScreen: View {
    @State private var goToDataSetting = false
    
    @StateObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        VStack {
            Text(settingViewModel.text)
            Button("Data Setting")
            {
                goToDataSetting = true
            }.navigationDestination(isPresented: $goToDataSetting){
                DataSettingScreen()
            }
        }.padding()
    }
    
}

#Preview {
    SettingScreen()
}

