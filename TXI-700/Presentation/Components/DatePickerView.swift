/*
 //  DataSerchBottom.swift
 //  TXI-700
 //
 //  Created by 서용준 on 12/3/25.
 */

import Foundation
import SwiftUI

struct DatePickerCustom: View {
    @ObservedObject var viewModel: DatePickerViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tempStart: Date
    @State private var tempEnd: Date
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    init(viewModel: DatePickerViewModel) {
        self.viewModel = viewModel
        self._tempStart = State(initialValue: viewModel.startDate)
        self._tempEnd = State(initialValue: viewModel.endDate)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 20) {
                    Text("StartDate")
                    DatePicker("", selection: $tempStart, in: viewModel.minDate...viewModel.maxDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .foregroundColor(tint)
                    
                    Text("EndDate")
                    DatePicker("", selection: $tempEnd, in: tempStart...viewModel.maxDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .foregroundColor(tint)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("SelectedPeriod")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirmation") {
                            viewModel.startDate = tempStart
                            viewModel.endDate = tempEnd
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
