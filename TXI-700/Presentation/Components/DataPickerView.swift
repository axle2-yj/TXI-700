//
//  DataSerchBottom.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import Foundation
import SwiftUI

struct DatePickerView: View {
    @ObservedObject var viewModel: DatePickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempStart: Date
    @State private var tempEnd: Date
    
    init(viewModel: DatePickerViewModel) {
        self.viewModel = viewModel
        self._tempStart = State(initialValue: viewModel.startDate)
        self._tempEnd = State(initialValue: viewModel.endDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("시작일")
                DatePicker("", selection: $tempStart, in: viewModel.minDate...viewModel.maxDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                Text("종료일")
                DatePicker("", selection: $tempEnd, in: tempStart...viewModel.maxDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("기간 선택")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        viewModel.startDate = tempStart
                        viewModel.endDate = tempEnd
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                        
                    }
                }
            }
        }
    }
}
