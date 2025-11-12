//
//  String+ext.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 04/11/25.
//

import Foundation

extension String {
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
