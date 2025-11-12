//
//  Array+ext.swift
//  MonKi
//
//  Created by William on 04/11/25.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
