//
//  WeightBalanceView.swift
//  TXI-700
//
//  Created by 서용준 on 12/24/25.
//

import SwiftUI

// MARK: - Axle Model
struct Axle {
    let left: CGFloat
    let right: CGFloat
}

// MARK: - Weight Balance View

struct WeightBalanceOverAxleView: View {
    /// 축 데이터 (2축 / 3축 / 4축 모두 대응)
    let axles: [Axle]
    
    // MARK: - 계산 로직
    
    /// 전체 하중
        private var total: CGFloat {
            max(axles.reduce(0) { $0 + $1.left + $1.right }, 1)
        }
        
        /// 좌 ↔ 우 밸런스
        private var xRatio: CGFloat {
            let leftTotal  = axles.reduce(0) { $0 + $1.left }
            let rightTotal = axles.reduce(0) { $0 + $1.right }
            return (rightTotal - leftTotal) / total
        }
        
        /// 앞 ↔ 뒤 밸런스
        /// - 규칙
        ///   - 1축만 앞
        ///   - 2축부터 뒤
        ///   - 3축 이상부터 앞 30% / 뒤 70% 가중치
        private var yRatio: CGFloat {
            let frontAxles = axles.prefix(1)
            let rearAxles  = axles.dropFirst(1)
            
            let front = frontAxles.reduce(0) { $0 + $1.left + $1.right }
            let rear  = rearAxles.reduce(0) { $0 + $1.left + $1.right }
            
            // 3축 이상부터 가중치 적용
            if axles.count >= 3 {
                let frontWeight: CGFloat = 0.3
                let rearWeight: CGFloat  = 0.7
                return ((front * frontWeight) - (rear * rearWeight)) / total
            } else {
                // 1축 / 2축
                return (front - rear) / total
            }
        }
        
        // MARK: - View
        var body: some View {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = size / 2
                
                let xOffset = xRatio * center
                let yOffset = -yRatio * center // SwiftUI 좌표계 보정
                
                ZStack {
                    
                    // 외곽 테두리
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                    
                    // 중심 기준선
                    Path { path in
                        path.move(to: CGPoint(x: center, y: 0))
                        path.addLine(to: CGPoint(x: center, y: size))
                        path.move(to: CGPoint(x: 0, y: center))
                        path.addLine(to: CGPoint(x: size, y: center))
                    }
                    .stroke(Color.gray.opacity(0.4))
                    
                    // Load Cell 라벨
                    loadCellLabels
                    
                    // 중심 점
                    Image(systemName: "circle.fill")
                        .foregroundColor(pointColor)
                        .offset(x: xOffset, y: yOffset)
                        .animation(.easeOut(duration: 0.2), value: xOffset)
                }
                .frame(width: size, height: size)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        
        // MARK: - Load Cell Labels
        private var loadCellLabels: some View {
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                
                let frontAxles = axles.prefix(1)
                let rearAxles  = axles.dropFirst(1)
                
                ZStack {
                    
                    // MARK: - Front Axle (항상 1축)
                    ForEach(frontAxles.indices, id: \.self) { _ in
                        let xLeft  = width * 0.15
                        let xRight = width * 0.85
                        let y = height * 0.25
                        
                        Text("L1")
                            .font(.caption)
                            .position(x: xLeft, y: y)
                        
                        Text("R1")
                            .font(.caption)
                            .position(x: xRight, y: y)
                    }
                    
                    // MARK: - Rear Axles (2축부터)
                    ForEach(rearAxles.indices, id: \.self) { index in
                        let axleIndex = index + 2
                        let xLeft  = width * 0.15
                        let xRight = width * 0.85
                        let y = height * (0.55 + CGFloat(index) * 0.12)
                        
                        Text("L\(axleIndex)")
                            .font(.caption)
                            .position(x: xLeft, y: y)
                        
                        Text("R\(axleIndex)")
                            .font(.caption)
                            .position(x: xRight, y: y)
                    }
                }
            }
        }
        
        // MARK: - Point Color
        private var pointColor: Color {
            abs(yRatio) > 0.25 ? .red : .green
        }
    }
