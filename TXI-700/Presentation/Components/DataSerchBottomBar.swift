//
//  DataSerchBottomBar.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import SwiftUI
import Combine
import Foundation

struct DataSerchBottomBar: View {
    @State private var showModal = false

    @ObservedObject var viewModel: DatePickerViewModel
    @ObservedObject var dataViewModel: DataViewModel

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        VStack {
            HStack {
                Text("DATE")
                    .frame(width: 80, alignment: .leading)
                Button(action: { showModal = true }) {
                    Text("\(viewModel.formattedRange)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)

                }.sheet(isPresented: $showModal) {
                    DatePickerCustom(viewModel: viewModel)
                }
            }
            HStack {
                Text("Vehicle No")
                    .frame(width: 80, alignment: .leading)
                TextField("차량번호 검색", text: $dataViewModel.filterVehicle)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                Text("Client")
                    .frame(width: 80, alignment: .leading)
                TextField("고객 검색", text: $dataViewModel.filterClient)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                Text("Item")
                    .frame(width: 80, alignment: .leading)
                TextField("품목 검색", text: $dataViewModel.filterProduct)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Button("Clear") {
                    dataViewModel.clearFilters()
                    viewModel.resetSerch()
                }
                .frame(maxWidth: .infinity) // 화면 절반 차지
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                .foregroundColor(.black)
                
                Button("Serch") {
                    dataViewModel.applyFilters(startDate: viewModel.startDate,
                                               endDate: viewModel.endDate)
                }
                .frame(maxWidth: .infinity) // 화면 절반 차지
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .foregroundColor(.white)
            }
        }
    }
}


