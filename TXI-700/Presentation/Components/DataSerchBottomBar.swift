//
//  DataSerchBottomBar.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import SwiftUI
import Combine
import Foundation

struct DataSearchBottomBar: View {
    @State private var showModal = false
    
    @ObservedObject var viewModel: DatePickerViewModel
    @ObservedObject var dataViewModel: DataViewModel
    
    @EnvironmentObject var languageManager: LanguageManager
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
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
                Text("Car No")
                    .frame(width: 80, alignment: .leading)
                CustomPlaceholderTextField(
                    placeholder: "VehicleNumSearch".localized(languageManager.selectedLanguage),
                    text: $dataViewModel.inputVehicle)
            }
            
            HStack {
                Text("Client")
                    .frame(width: 80, alignment: .leading)
                CustomPlaceholderTextField(
                    placeholder: "ClientSearch".localized(languageManager.selectedLanguage),
                    text: $dataViewModel.inputClient)
            }
            
            HStack {
                Text("Item")
                    .frame(width: 80, alignment: .leading)
                CustomPlaceholderTextField(
                    placeholder: "ProductSearch".localized(languageManager.selectedLanguage),
                    text: $dataViewModel.inputProduct)
            }
            HStack {
                Button {
                    dataViewModel.clearFilters()
                    viewModel.resetSerch()
                } label: {
                    Text("Clear".localized(languageManager.selectedLanguage))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(tint)
                        .contentShape(Rectangle())
                }
                
                Button {
                    dataViewModel.applyFilters(startDate: viewModel.startDate,
                                               endDate: viewModel.endDate)
                } label: {
                    Text("Search".localized(languageManager.selectedLanguage))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(tint)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}


