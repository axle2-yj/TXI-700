//
//  CarRegionDropdown.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI

struct CarRegionDropdown: View {
    
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
                List {
                    // "없음" 항목 추가
                    Text(NSLocalizedString("None", comment: ""))
                        .foregroundColor(.red)
                        .onTapGesture {
                            viewModel.selectedRegion = ""  // 빈 문자열로 저장
                            showSheet = false
                        }
                                    
                    // 기존 지역 리스트
                    ForEach(viewModel.items, id: \.self) { item in
                    Text(item)
                            .padding(.vertical, 8)
                            .onTapGesture {
                            viewModel.selectedRegion = item
                            showSheet = false
                            }
                        }
                    }
                    .navigationTitle("지역 선택")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") { showSheet = false }
                        }
                    }
                }
            }
        }
    }
