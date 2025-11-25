//
//  VehicleViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class VehicleViewModel: ObservableObject {
    @Published var text: String = "Vehicle Screen 출력"
}
