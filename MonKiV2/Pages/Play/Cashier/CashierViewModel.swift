//
//  CashierViewModel.swift
//  MonKiV2
//
//  Created by William on 14/11/25.
//

import SwiftUI

@Observable
final class CashierViewModel {
    weak var parent: PlayViewModel?

    init(parent: PlayViewModel?) {
        self.parent = parent
    }
}
