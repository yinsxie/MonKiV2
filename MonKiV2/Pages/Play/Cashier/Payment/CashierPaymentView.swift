//
//  CashierPaymentView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

// MARK: - adjust later by will's UI/Layout
import SwiftUI

struct CashierPaymentView: View {
    
    @Environment(CashierViewModel.self) var viewModel
    @Environment(PlayViewModel.self) var playVM
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.green.opacity(0.3))
                .frame(width: 250, height: 600)
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
                
                VStack(spacing: 5) {
                    ForEach(viewModel.receivedMoney.reversed()) { money in
                        MoneyView(money: money)
                            .scaleEffect(0.6)
                    }
                }
                
                HStack {
                    Button {
                        playVM.onCancelPayment()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    PlayViewContainer(forGameMode: .singleplayer)
}
