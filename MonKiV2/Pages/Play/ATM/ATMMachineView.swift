//
//  ATMMachineView.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 19/11/25.
//

import SwiftUI

struct ATMMachineView: View {
    @Environment(ATMViewModel.self) var atmVM
    var balanceShown: Bool = true
    
    private var isAnyCooldownActive: Bool {
        return atmVM.activeCooldownProgress > 0
    }
    
    var body: some View {
        ZStack {
            Image("ATM_Machine")
                .resizable()
                .scaledToFit()
                .frame(width: 342, height: 650)
            
            VStack {
                if !balanceShown {
                    Image("ATM_Screen_Placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 225, height: 140)
                } else {
                    HStack {
                        // MARK: - KIRI: SALDO, COOLDOWN, NOMINAL
                        VStack(spacing: 8) {
                            Text("Saldo: \(atmVM.atmBalance)")
                                .font(.VT323(size: 28))
                                .foregroundStyle(ColorPalette.cashierNominal)
                                .padding(.leading, 40)
                            
                            HStack {
                                Spacer()
                                PieSlice(progress: atmVM.activeCooldownProgress)
                                    .fill(ColorPalette.cashierNominal)
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                    .padding(.trailing, 24)
                                    .opacity(atmVM.activeCooldownProgress > 0 ? 1 : 0)
                                
                                VStack(spacing: 6) {
                                    WithdrawNominalText(amount: 10, isSelected: atmVM.flyingMoneyValue == 10, isDisabled: atmVM.isButtonDisabled(amount: 10) || atmVM.isProcessing)
                                        .accessibilityLabel("Tombol tarik uang 10")
                                    WithdrawNominalText(amount: 20, isSelected: atmVM.flyingMoneyValue == 20, isDisabled: atmVM.isButtonDisabled(amount: 20) || atmVM.isProcessing)
                                        .accessibilityLabel("Tombol tarik uang 20")
                                    WithdrawNominalText(amount: 50, isSelected: atmVM.flyingMoneyValue == 50, isDisabled: atmVM.isButtonDisabled(amount: 50) || atmVM.isProcessing)
                                        .accessibilityLabel("Tombol tarik uang 50")
                                }.padding(.trailing, 8)
                                    .opacity(atmVM.activeCooldownProgress > 0 ? 0 : 1)
                            }
                        }
                        
                        // MARK: - KANAN: TOMBOL
                        VStack(spacing: 14) {
                            Spacer()
                            
                            let disableGlobal = isAnyCooldownActive
                            let is10InDelay = atmVM.flyingMoneyValue == 10
                            let is20InDelay = atmVM.flyingMoneyValue == 20
                            let is50InDelay = atmVM.flyingMoneyValue == 50
                            
                            // Button 1: Withdraw 10
                            WithdrawButton(amount: 10, isDelayed: is10InDelay, isDisabled: atmVM.isButtonDisabled(amount: 10) || disableGlobal)
                            
                            // Button 2: Withdraw 20
                            WithdrawButton(amount: 20, isDelayed: is20InDelay, isDisabled: atmVM.isButtonDisabled(amount: 20) || disableGlobal)
                            
                            // Button 3: Withdraw 50
                            WithdrawButton(amount: 50, isDelayed: is50InDelay, isDisabled: atmVM.isButtonDisabled(amount: 50) || disableGlobal)
                            
                        }.frame(alignment: .bottom)
                            .padding(.leading, 12)
                            .padding(.bottom, 8)
                    }
                    .padding(.vertical, 16)
                    .frame(width: 280, height: 163, alignment: .top)
                }
            }
            .offset(y: -127)
            
            Image("ATM_Glass")
                .resizable()
                .scaledToFit()
                .frame(width: 225, height: 140)
                .offset(y: -127)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .animation(.easeInOut(duration: 0.3), value: atmVM.isZoomed)
        .disabled(!atmVM.isZoomed)
    }
}

// MARK: - CUSTOM COMPONENT: buat underline pas selected
struct WithdrawNominalText: View {
    let amount: Int
    let isSelected: Bool
    let isDisabled: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(amount)")
                .font(.VT323(size: 24))
                .foregroundStyle(ColorPalette.cashierNominal)
                .lineLimit(1)
            
            Rectangle()
                .fill(ColorPalette.cashierNominal)
                .frame(width: 16, height: 2)
                .opacity(isSelected ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
    }
}

// MARK: - CUSTOM COMPONENT: buat handle state buttonnya
struct WithdrawButton: View {
    @Environment(ATMViewModel.self) var atmVM
    let amount: Int
    let isDelayed: Bool
    let isDisabled: Bool
    private var buttonMultiplyColor: Color {
        return isDelayed ? ColorPalette.delayATMButton : Color.white
    }
    
    var body: some View {
        Button(action: {
            print("Withdraw \(amount) clicked")
            if !isDisabled {
                atmVM.withdraw(amount: amount)
            }
        }, label: {
            Image("ATM_Button")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 17)
                .colorMultiply(buttonMultiplyColor)
                .opacity(isDisabled ? 0.5 : 1.0)
        })
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.3), value: buttonMultiplyColor)
    }
}
