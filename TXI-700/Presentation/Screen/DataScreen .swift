//
//  DataScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataScreen: View {
    @StateObject var viewModel = DataViewModel()
    @StateObject var datePickerViewModel = DatePickerViewModel()
    
    @State private var goToDetail = false
    @State private var selectedItem: LoadAxleInfo? = nil
    @State private var selectedItemIndex : Int?
    @State private var showFilterBar = true

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    @EnvironmentObject var bleManager: BluetoothManager
    
    // 필터 적용 후 그룹화된 데이터
    private var groupedItems: [String: [LoadAxleInfo]] {
        Dictionary(grouping: viewModel.filteredItems) { item in
            if let date = item.timestamp {
                return viewModel.dateFormatter.string(from: date)
            }
            return "Unknown Date"
        }
    }
    
    var body: some View {
        ZStack{
            VStack {
                if viewModel.filteredItems.isEmpty {
                    Spacer()
                    Text("No Data")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(groupedItems.keys.sorted(by: >), id: \.self) { dateKey in
                            Section(header: Text(dateKey).font(.headline)) {
                                ForEach(items(for: dateKey)) { item in
                                    LoadAxleRow(item: item, timestampFormatter: viewModel.timeFormatter)
                                        .onTapGesture {
                                            selectedItem = item
                                            selectedItemIndex = viewModel.filteredItems.firstIndex(of: item)
                                            goToDetail = true
                                        }
                                }
                            }
                        }
                    }
                    .navigationDestination(isPresented: $goToDetail) {
                        if let item = selectedItem,
                           let index = selectedItemIndex{
                            DataDetailScreen(currentIndex: index,
                                            loadAxleItem: item,
                                            viewModel: viewModel,
                                            printViewModel: printViewModel,
                                            settingViewMdoel: settingViewModel)
                        }
                    }
                                    
                }
            }
            .padding()
            .onAppear {
                viewModel.currentEquipmentNumber = bleManager.equipmentNumber
                viewModel.fetchLoadAxleItems()
            }
        }.safeAreaInset(edge: .top) {
            // MARK: - Top Bar
            CustomTopBar(title: viewModel.title, onBack: {
                presentationMode.wrappedValue.dismiss()
            })
        }.safeAreaInset(edge: .bottom) {
            VStack {
                // MARK: - Bottom Bar
                Button(action: { showFilterBar.toggle() }) {
                    HStack {
                        Image("return")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(showFilterBar ? 270 : 90))
                            .animation(.easeInOut(duration: 0.2), value: showFilterBar)
                    }.frame(height: 30)
                }
                if showFilterBar {
                    DataSerchBottomBar(viewModel: datePickerViewModel, dataViewModel: viewModel)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showFilterBar)
                }
            }.padding(.horizontal, 15)
        }.navigationBarBackButtonHidden(true)
    }
    
    // 특정 날짜의 항목 정렬
    private func items(for dateKey: String) -> [LoadAxleInfo] {
        (groupedItems[dateKey] ?? []).sorted {
            ($0.timestamp ?? Date.distantPast) > ($1.timestamp ?? Date.distantPast)
        }
    }
}

struct LoadAxleRow: View {
    let item: LoadAxleInfo
    let timestampFormatter: DateFormatter
    
    var body: some View {
        HStack {
            Text("\(item.timestamp.map { timestampFormatter.string(from: $0) } ?? "N/A")")
            Text("No : \(item.vehicle ?? "N/A")")
            Text("\(item.product ?? "N/A")")
        }
        .padding(4)
    }
}
