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
    let isEdgeTotals: Int
    
    @ObservedObject var viewModel: SettingViewModel
    
    // MARK: - 계산 로직
    
    // 전체 하중
    private var total: CGFloat {
        max(axles.reduce(0) { $0 + $1.left + $1.right }, 1)
    }
    
    // 좌 ↔ 우 벨런스
    private var xRatio: CGFloat {
        let leftTotal  = axles.reduce(0) { $0 + $1.left }
        let rightTotal = axles.reduce(0) { $0 + $1.right }
        return (rightTotal - leftTotal) / total
    }
    
    /*
     상 ↔ 하 벨런스
     - 규칙
     - 1축만 앞
     - 2축부터 뒤
     */
    
    private var yRatio: CGFloat {
        let frontAxles = axles.prefix(1)
        let rearAxles  = axles.dropFirst(1)
        
        let front = frontAxles.reduce(0) { $0 + $1.left + $1.right }
        let rear  = rearAxles.reduce(0) { $0 + $1.left + $1.right }
        
        
        return (front - rear) / total
    }
    
    private var leftTotal: CGFloat {
        axles.reduce(0) { $0 + $1.left }
    }
    
    private var rightTotal: CGFloat {
        axles.reduce(0) { $0 + $1.right }
    }
    
    private var frontTotal: CGFloat {
        axles.prefix(1).reduce(0) { $0 + $1.left + $1.right }
    }
    
    private var rearTotal: CGFloat {
        axles.dropFirst(1).reduce(0) { $0 + $1.left + $1.right }
    }
    
    
    private var leftRatio: CGFloat {
        leftTotal / total
    }
    
    private var rightRatio: CGFloat {
        rightTotal / total
    }
    
    private var frontRatio: CGFloat {
        frontTotal / total
    }
    
    private var rearRatio: CGFloat {
        rearTotal / total
    }
    
    private var dangerousThreshold: CGFloat { CGFloat(viewModel.dangerous) / 100.0 }
    private var cautionThreshold: CGFloat  { CGFloat(viewModel.caution)  / 100.0 }
    private var safetyThreshold: CGFloat    { CGFloat(viewModel.safety)    / 100.0 }
    
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
                if axles.count == 2 {
                    Image("TRUCK_4pad")
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                } else if axles.count == 3 {
                    Image("TRUCK_6pad")
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                }
                // 중심 기준선
                Path { path in
                    path.move(to: CGPoint(x: center, y: 0))
                    path.addLine(to: CGPoint(x: center, y: size))
                    path.move(to: CGPoint(x: 0, y: center))
                    path.addLine(to: CGPoint(x: size, y: center))
                }
                .stroke(Color.gray.opacity(0.4))
                
                if isEdgeTotals == 1{
                    // 🔹 방향별 합계
                    edgeTotals(size: size)
                }
                
                // Load Cell 라벨
                //                loadCellLabels
                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    let center = size / 2
                    
                    let radius10 = center * safetyThreshold
                    let radius15 = center * cautionThreshold
                    let radius25 = center * dangerousThreshold
                    ZStack {
                        // 🟢 10% 파란 고리
                        Circle()
                            .stroke(Color.green, lineWidth: 2)
                            .frame(width: radius10 * 2, height: radius10 * 2)
                        
                        // 🟠 15% 주황 고리
                        Circle()
                            .stroke(Color.orange, lineWidth: 2)
                            .frame(width: radius15 * 2, height: radius15 * 2)
                        
                        // 🔴 25% 빨간 고리
                        Circle()
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: radius25 * 2, height: radius25 * 2)
                    }.position(x: center,
                               y: center)
                }
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
    
    //    // MARK: - Load Cell Labels
    //    private var loadCellLabels: some View {
    //        GeometryReader { geo in
    //            let width = geo.size.width
    //            let height = geo.size.height
    //            
    //            let frontAxles = axles.prefix(1)
    //            let rearAxles  = axles.dropFirst(1)
    //            
    //            ZStack {
    //                
    //                // MARK: - Front Axle (항상 1축)
    //                ForEach(frontAxles.indices, id: \.self) { _ in
    //                    let xLeft  = width * 0.15
    //                    let xRight = width * 0.85
    //                    let y = height * 0.25
    //                    
    //                    Text("L1")
    //                        .font(.caption)
    //                        .position(x: xLeft, y: y)
    //                    
    //                    Text("R1")
    //                        .font(.caption)
    //                        .position(x: xRight, y: y)
    //                }
    //                
    //                // MARK: - Rear Axles (2축부터)
    //                ForEach(rearAxles.indices, id: \.self) { index in
    //                    let axleIndex = index + 2
    //                    let xLeft  = width * 0.15
    //                    let xRight = width * 0.85
    //                    let y = height * (0.55 + CGFloat(index) * 0.12)
    //                    
    //                    Text("L\(axleIndex)")
    //                        .font(.caption)
    //                        .position(x: xLeft, y: y)
    //                    
    //                    Text("R\(axleIndex)")
    //                        .font(.caption)
    //                        .position(x: xRight, y: y)
    //                }
    //            }
    //        }
    //    }
    
    
    // MARK: - Point Color
    /**
     🔴 25% 초과 = 이미 위험
     🟠 경고는 10~15%부터 주는 게 현실적
     🟢 정상 범위는 ±5~10%
     */
    
    private var pointColor: Color {
        let x = abs(xRatio)
        let y = abs(yRatio)
        
        if x > cautionThreshold || y > dangerousThreshold {
            return .red          // 위험
        } else if x > safetyThreshold || y > cautionThreshold {
            return .orange       // 경고
        } else {
            return .green        // 정상
        }
    }
    
    // MARK: - Edge Totals View
    private func edgeTotals(size: CGFloat) -> some View {
        ZStack {
            // TOP (Front)
            edgeValue(
                title: "FRONT",
                value: frontTotal,
                ratio: frontRatio
            )
            .position(x: size / 2, y: 14)
            
            // BOTTOM (Rear)
            edgeValue(
                title: "REAR",
                value: rearTotal,
                ratio: rearRatio
            )
            .position(x: size / 2, y: size - 14)
            
            // LEFT
            edgeValue(
                title: "LEFT",
                value: leftTotal,
                ratio: leftRatio
            )
            .position(x: 22, y: size / 2)
            
            // RIGHT
            edgeValue(
                title: "RIGHT",
                value: rightTotal,
                ratio: rightRatio
            )
            .position(x: size - 22, y: size / 2)
        }
    }
    
    // MARK: - Edge Value View
    private func edgeValue(
        title: String,
        value: CGFloat,
        ratio: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
            if title == "LEFT" || title == "RIGHT" {
                Text("\(Int(value))")
                    .font(.caption)
                    .bold()
                
                Text(String(format: "%.0f%%", ratio * 100))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Text("\(Int(value))")
                        .font(.caption)
                        .bold()
                    
                    Text(String(format: "%.0f%%", ratio * 100))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
