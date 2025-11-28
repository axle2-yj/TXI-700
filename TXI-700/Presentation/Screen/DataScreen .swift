//
//  DataScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataScreen: View {
    @State private var goToDetail = false
    
    @StateObject var viewModel = DataViewModel()
    
    // Timestamp Formatter
        let timestampFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm"
            return f
        }()
    
    var body: some View {
        VStack {
            Text("Data Screen")
            Button("Data Detail Screen")
            {
                goToDetail = true
            }.navigationDestination(isPresented: $goToDetail){
                DataDetailScreen()
            }
            if viewModel.loadAxleItems.isEmpty {
                            Text("No Data")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            List(viewModel.loadAxleItems, id: \.self) { item in
                                VStack(alignment: .leading) {
                                    Text("Timestamp: \(item.timestamp.map { timestampFormatter.string(from: $0) } ?? "N/A")")
                                    Text("Vehicle: \(item.vehicle ?? "N/A")")
                                    Text("Client: \(item.client ?? "N/A")")
                                    Text("Product: \(item.product ?? "N/A")")
                                    
                                    if let data = item.loadAxleData,
                                       let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
                                        Text("Load Axles1: \(loadAxles.indices.contains(0) ? String(loadAxles[0]) : "0"), " +
                                             "\(loadAxles.indices.contains(1) ? String(loadAxles[1]) : "0")")
                                        Text("Load Axles2: \(loadAxles.indices.contains(2) ? String(loadAxles[2]) : "0"), " +
                                             "\(loadAxles.indices.contains(3) ? String(loadAxles[3]) : "0")")
                                    }
                                }
                                .padding(4)
                            }
                        }
        }.padding()
            .onAppear {
            viewModel.fetchLoadAxleItems()
        }
    }
}

#Preview {
    DataScreen()
}

