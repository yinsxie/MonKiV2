//
//  FloatingPriceFeedbackModifier.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//
import SwiftUI

struct PriceChangeFeedbackModifier: ViewModifier {
    var currentValue: Int
    
    @State private var previousValue: Int
    @State private var floatingItems: [FloatingPriceTextData] = []
    
    init(value: Int) {
        self.currentValue = value
        self._previousValue = State(initialValue: value)
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(floatingItems) { item in
                        FloatingPriceTextView(data: item) { id in
                            floatingItems.removeAll(where: { $0.id == id })
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            .onChange(of: currentValue) { oldValue, newValue in
                let diff = newValue - oldValue
                
                let newItem = FloatingPriceTextData(value: diff)
                floatingItems.append(newItem)
                
                previousValue = newValue
            }
    }
}

extension View {
    func floatingPriceFeedback(value: Int) -> some View {
        self.modifier(PriceChangeFeedbackModifier(value: value))
    }
}
