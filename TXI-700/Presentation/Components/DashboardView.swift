//
//  DashboardView.swift
//  TXI-700
//
//  Created by 서용준 on 1/6/26.
//
import SwiftUI
import Combine

struct DashboardView: View {
    
    @EnvironmentObject var bleManager: BluetoothManager
    @StateObject private var viewModel: DashboardViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                axleStates: Just([]).eraseToAnyPublisher(),
                weightMode: Just(.staticMode).eraseToAnyPublisher()
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("Mode: \(viewModel.weightMode.title)")
            ForEach(viewModel.axles) { axle in
                Text("Axle \(axle.id): \(axle.leftWeightText) / \(axle.rightWeightText)")
            }
        }
        .onAppear {
            viewModel.bind(
                axleStates: bleManager.axlesPublisher,
                weightMode: bleManager.weightModePublisher
            )
        }
    }
}
