//
//  CashierPaymentView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

// MARK: - adjust later by will's UI/Layout
import SwiftUI

struct CashierPaymentView: View {
    
    var viewModel: CashierViewModel
    @Environment(DragManager.self) var manager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.green.opacity(0.3))
                .frame(width: 250, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.green, lineWidth: 2)
                )
            
            VStack {
                Text("Payment Counter")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Received: \(viewModel.totalReceivedMoney.formatted())")
                    .font(.title2.bold())
                    .foregroundColor(.green)
                
                 HStack {
                     ForEach(viewModel.receivedMoney.reversed()) { money in
                         MoneyView(money: money)
                             .scaleEffect(0.6)
                     }
                 }
            }
        }
        .makeDropZone(type: .cashierPaymentCounter)
    }
}

#Preview {
    CashierPaymentView(viewModel: CashierViewModel())
}
