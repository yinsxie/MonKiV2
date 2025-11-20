//
//  ViewFrameKey.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 18/11/25.
//

import SwiftUI

struct ViewFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
