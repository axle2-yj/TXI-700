//
//  WeightBalanceView.swift
//  TXI-700
//
//  Created by 서용준 on 12/24/25.
//

import SwiftUI

struct WeightBalanceView: View {
    let left1: CGFloat
    let right1: CGFloat
    let left2: CGFloat
    let right2: CGFloat

    private var total: CGFloat {
            max(left1 + right1 + left2 + right2, 1)
        }

        private var xRatio: CGFloat {
            ((right1 + right2) - (left1 + left2)) / total
        }

        private var yRatio: CGFloat {
            ((left1 + right1) - (left2 + right2)) / total
        }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = size / 2
            
            let total = max(left1 + right1 + left2 + right2, 1)
            
            let xRatio = ((right1 + right2) - (left1 + left2)) / total
            let yRatio = ((left1 + right1) - (left2 + right2)) / total
            
            let xOffset = xRatio * center
            let yOffset = -yRatio * center   // SwiftUI 좌표계 보정
            
            ZStack {
                // 외곽 사각형
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                
//                Image("car")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: size, height: size)
//                    .clipped()
                
                // 중심 기준선
                Path { path in
                    path.move(to: CGPoint(x: center, y: 0))
                    path.addLine(to: CGPoint(x: center, y: size))
                    path.move(to: CGPoint(x: 0, y: center))
                    path.addLine(to: CGPoint(x: size, y: center))
                }
                .stroke(Color.gray.opacity(0.4))
                
                // 꼭지점 텍스트
                VStack {
                    HStack {
                        Text("Load cell 1")
                            .font(.caption)
                        Spacer()
                        Text("Load cell 2")
                            .font(.caption)
                    }
                    Spacer()
                    HStack {
                        Text("Load cell 3")
                            .font(.caption)
                        Spacer()
                        Text("Load cell 4")
                            .font(.caption)
                    }
                }
                
                // 움직이는 점
                Image(systemName: "circle.fill")
                    .foregroundColor(pointColor)
                    .offset(x: xOffset, y: yOffset)
                    .animation(.easeOut(duration: 0.2), value: xOffset)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Point Color
    private var pointColor: Color {
        abs(yRatio) > 0.25 ? .red : .green
    }
}
