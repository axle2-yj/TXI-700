//
//  WeightModeViewStateMapper.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

struct WeightModeViewStateMapper {
    
    static func map(_ mode: WeightMode) -> WeightModeViewState {
        switch mode {
        case .staticMode:
            return WeightModeViewState(
                title: "Static",
                description: "정지 계량 모드",
                selectedIndex: 0
            )
            
        case .inmotionMode:
            return WeightModeViewState(
                title: "Inmotion",
                description: "주행 계량 모드",
                selectedIndex: 1
            )
            
        case .autoInmotionMode:
            return WeightModeViewState(
                title: "Auto Inmotion",
                description: "자동 주행 계량 모드",
                selectedIndex: 2
            )
        }
    }
}
