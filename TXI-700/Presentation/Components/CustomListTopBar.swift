/*
 CustomTopBara.swift
 
 TXI-700
 
 - 이전 버튼, 타이틀, 추가 버튼 TopBar
 
 Created by 서용준 on 11/24/25.
 */

import SwiftUI

struct CustomListTopBar: View {
    @State private var isAddMode = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var onBack: () -> Void
    var onChange: (Bool) -> Void
    private var crossImage: String {
        colorScheme == .dark ? "cross_dark" : "cross"
    }
    
    private var plusImage: String {
        colorScheme == .dark ? "plus_dark" : "plus"
    }
    
    private var returnImage: String {
        colorScheme == .dark ? "return_dark" : "return"
    }
    var body: some View {
        ZStack {
            // 가운데: 타이틀
            Text(title)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Button(action: onBack) {
                    Image(returnImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                Button(action: {
                    isAddMode.toggle()
                    onChange(isAddMode)
                }) {
                    Image(isAddMode ? plusImage : crossImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
                        .animation(.spring(), value: isAddMode)
                }
            }.padding(.horizontal)
            
        }
        .frame(height: 50)
        .background(Color(.systemGray6))
    }
}
