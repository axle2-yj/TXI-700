//
//  MainViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var text: String = "Main Screen 출력"
}
