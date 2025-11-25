//
//  HomeScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataDetailScreen: View {
    @StateObject var dataViewModel = DataViewModel()
    
    var body: some View {
        VStack {
            Text("Data Detail Screen")
        }.padding()
    }
}

#Preview {
    DataDetailScreen()
}

