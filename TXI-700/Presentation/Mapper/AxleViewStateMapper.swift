//
//  AxleViewStateMapper.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

struct AxleViewStateMapper {
    
    static func map(_ state: AxleState) -> AxleViewState {
        AxleViewState(
            id: state.axle,
            leftWeightText: weight(state.leftWeight),
            rightWeightText: weight(state.rightWeight),
            leftBatteryText: battery(state.leftBatteryLevel),
            rightBatteryText: battery(state.rightBatteryLevel)
        )
    }
    
    private static func weight(_ value: Int?) -> String {
        guard let value else { return "--" }
        return "\(value) kg"
    }
    
    private static func battery(_ value: Int?) -> String {
        guard let value else { return "--" }
        return "🔋 \(value)"
    }
}
