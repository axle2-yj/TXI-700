//
//  WeightModeViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//
import SwiftUI
import Combine

@MainActor
final class WeightModeViewModel: ObservableObject {
    // 🔹 UI가 바로 바인딩할 상태
    @Published private(set) var viewState: WeightModeViewState
    
    // 🔹 초기화 (초기 Domain 값 주입)
    init(initialMode: WeightMode) {
        self.viewState = WeightModeViewStateMapper.map(initialMode)
    }
    
    // 🔹 Domain 변경 시 ViewState 갱신
    func update(mode: WeightMode) {
        self.viewState = WeightModeViewStateMapper.map(mode)
    }
}

