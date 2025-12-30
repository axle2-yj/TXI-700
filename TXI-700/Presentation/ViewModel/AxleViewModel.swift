//
//  AxleViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

import Foundation
import Combine
@MainActor

final class AxleViewModel: ObservableObject {
    
    // UI가 직접 보는 상태
    @Published private(set) var axles: [AxleViewState] = []
    
    private let manager: BluetoothManager
    private var cancellables = Set<AnyCancellable>()
    
    init(manager: BluetoothManager) {
        self.manager = manager
        bind()
    }
    
    private func bind() {
        manager.$axles
            .map { domainAxles in
                domainAxles.values
                    .sorted { $0.axle < $1.axle }
                    .map(AxleViewStateMapper.map)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$axles)
    }
}
