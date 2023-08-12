//
//  Float4x4+Extensions.swift
//  AR-Demo
//
//  Created by Seven Tsai on 2023/8/12.
//

import Foundation

extension float4x4 {
    var translation: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3(translation.x, translation.y, translation.z)
    }
}
