//
//  DataSettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataSettingScreen: View {
    @StateObject var settingDataPrintViewModel = SettingDataPrintViewModel()
    
    var body: some View {
        VStack {
            Text(settingDataPrintViewModel.text)
            
        }.padding()
    }
    
}

#Preview {
    DataSettingScreen()
}

