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
            .overlay(alignment: .top) { // Align top so they float up from the center-top
                ZStack {
                    ForEach(floatingItems) { item in
                        FloatingPriceTextView(data: item) { id in
                            // Remove item from array when animation is done
                            floatingItems.removeAll(where: { $0.id == id })
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            .onChange(of: currentValue) { oldValue, newValue in
                let diff = newValue - oldValue
                
                if diff != 0 {
                    let color: Color = diff > 0 ? .green : .red
                    
                    let newItem = FloatingPriceTextData(value: diff, color: color)
                    floatingItems.append(newItem)
                }
                
                // Update tracker
                previousValue = newValue
            }
    }
}

extension View {
    func floatingPriceFeedback(value: Int) -> some View {
        self.modifier(PriceChangeFeedbackModifier(value: value))
    }
}
