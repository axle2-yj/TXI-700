//
//  CarRegionDropdown.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI

struct VehicleRegionDropdown: View {
    @State private var showSheet: Bool = false
    
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var activeAlert: ActiveListAlert?
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var bleManager: BluetoothManager
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                VStack {
                    // 드롭다운 버튼: 텍스트로 현재 선택 지역 표시
                    
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showSheet = true
                            }
                        }) {
                            HStack {
                                Text(viewModel.selectedRegion.isEmpty ? String("Region").localized(languageManager.selectedLanguage) : viewModel.selectedRegion)
                                    .foregroundColor(viewModel.selectedRegion.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .cornerRadius(6)
                            // 차량번호 입력
                            
                        }
                        
                        
                        CustomPlaceholderTextField(
                            placeholder: "VehicleNum".localized(languageManager.selectedLanguage),
                            text: $viewModel.vehicle)
                        .frame(maxWidth: .infinity)
                    }
                    // 무게 입력
                    CustomPlacholderNumberTextField(
                        placeholder: "WeightInput".localized(languageManager.selectedLanguage),
                        text: $viewModel.weight)
                }
                
                // 저장 버튼
                SaveOrUpdateButton(
                    title: viewModel.selectedVehicle == nil ? "Save".localized(languageManager.selectedLanguage) : "Update".localized(languageManager.selectedLanguage),
                    onButton:{
                        guard !viewModel.vehicle.isEmpty else {
                            activeAlert = .error("VehicleError".localized(languageManager.selectedLanguage))
                            return
                        }
                        viewModel.saveOrUpdateVehicleItem()
                    }
                ).onReceive(viewModel.$saveSuccessMessage) { message in
                    guard message != nil else { return }
                    activeAlert = .success(message ?? "")
                }.onReceive(viewModel.$saveFailedMessage) { message in
                    guard message != nil else { return }
                    activeAlert = .error(message ?? "")
                }
                
                if viewModel.selectedVehicle != nil {
                    Button("Cancel") {
                        viewModel.clearSelection()
                    }
                    .foregroundColor(Color.red)
                }
            }
            .padding(.horizontal)
            
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                VStack {
                    CustomPlaceholderTextField(placeholder: "Search", text: $viewModel.searchText)
                        .padding(.horizontal)
                    List {
                        // "없음" 항목
                        HStack {
                            Text("None")
                            Spacer()
                        }.foregroundColor(.red)
                            .padding(8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedRegion = ""
                                showSheet = false
                            }
                        
                        // 검색 필터 적용
                        ForEach(viewModel.items.filter {
                            viewModel.searchText.isEmpty ? true : $0.contains(viewModel.searchText)
                        }, id: \.self) { item in
                            HStack {
                                Text(item)
                                Spacer()
                                if viewModel.selectedRegion == item {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedRegion = item
                                showSheet = false
                            }
                            
                        }
                    }
                }
                .navigationTitle("SelectRegion")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showSheet = false
                        }
                    }
                }
            }
        }.onChange(of: languageManager.selectedLanguage) { _, _ in
            viewModel.updateLanguage(languageManager.selectedLanguage)
        }
        .onAppear {
            viewModel.updateLanguage(languageManager.selectedLanguage)
            viewModel.saveSuccessMessage = nil
        }.onDisappear {
            viewModel.saveSuccessMessage = nil
        }
    }
}
