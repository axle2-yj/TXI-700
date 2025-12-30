//
//  WeightModeViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 1/6/26.
//

import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - View States
    @Published private(set) var axles: [AxleViewState] = []
    @Published private(set) var weightMode: WeightModeViewState
    
    // MARK: - Private
    private let weightModeViewModel: WeightModeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        axleStates: AnyPublisher<[AxleState], Never>,
        weightMode: AnyPublisher<WeightMode, Never>
    ) {
        self.weightModeViewModel = WeightModeViewModel(initialMode: .staticMode)
        self.weightMode = weightModeViewModel.viewState
        
        bindAxles(axleStates)
        bindWeightMode(weightMode)
    }
}


extension DashboardViewModel {
    func bind(
        axleStates: AnyPublisher<[AxleState], Never>,
        weightMode: AnyPublisher<WeightMode, Never>
    ) {
        bindAxles(axleStates)
        bindWeightMode(weightMode)
    }
    
    private func bindAxles(_ publisher: AnyPublisher<[AxleState], Never>) {
        publisher
            .map { states in
                states
                    .sorted { $0.axle < $1.axle }
                    .map(AxleViewStateMapper.map)
            }
            .assign(to: &$axles)
    }
    
    private func bindWeightMode(_ publisher: AnyPublisher<WeightMode, Never>) {
        publisher
            .removeDuplicates()
            .sink { [weak self] mode in
                guard let self else { return }
                self.weightModeViewModel.update(mode: mode)
                self.weightMode = self.weightModeViewModel.viewState
            }
            .store(in: &cancellables)
    }
}
