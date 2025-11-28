//
//  CarRegionDropdown.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI

struct VehicleRegionDropdown: View {
    
    @ObservedObject var viewModel: VehicleViewModel
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                VStack {
                    // 드롭다운 버튼: 텍스트로 현재 선택 지역 표시
                    Button(action: {
                        withAnimation(.easeInOut) {
                            showSheet = true
                        }
                    }) {
                        HStack {
                            HStack {
                                Text(viewModel.selectedRegion.isEmpty ? NSLocalizedString("Region", comment: "") : viewModel.selectedRegion)
                                    .foregroundColor(viewModel.selectedRegion.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            
                            
                            // 차량번호 입력
                            TextField(NSLocalizedString("VehicleNum", comment: ""), text: $viewModel.vehicle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    
                    // 무게 입력
                    TextField(NSLocalizedString("WeightInput", comment: ""), text: $viewModel.weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                // 저장 버튼
                Button("Save") {
                    viewModel.addVehicleItem()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                VStack {
                    TextField("Search", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                .navigationTitle("\(NSLocalizedString("SelectRegion", comment: ""))")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("\(NSLocalizedString("Close", comment: ""))") { showSheet = false }
                    }
                }
            }
        }
    }
}
