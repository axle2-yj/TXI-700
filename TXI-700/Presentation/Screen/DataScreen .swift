//
//  HomeScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataScreen: View {
    @State private var goToDetail = false
    
    var body: some View {
        VStack {
            Text("Data Screen")
            Button("Main")
            {
                goToDetail = true
            }.navigationDestination(isPresented: $goToDetail){
                DataDetailScreen()
            }
        }.padding()
    }
}

#Preview {
    DataScreen()
}

