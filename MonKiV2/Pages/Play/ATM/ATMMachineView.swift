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
                                    Text("10").font(.VT323(size: 24)).foregroundStyle(atmVM.isButtonDisabled(amount: 10) ? ColorPalette.disableATM : ColorPalette.cashierNominal)
                                    Text("20").font(.VT323(size: 24)).foregroundStyle(atmVM.isButtonDisabled(amount: 20) ? ColorPalette.disableATM : ColorPalette.cashierNominal)
                                    Text("50").font(.VT323(size: 24)).foregroundStyle(atmVM.isButtonDisabled(amount: 50) ? ColorPalette.disableATM : ColorPalette.cashierNominal)
                                }.padding(.trailing, 8)
                                .opacity(atmVM.activeCooldownProgress > 0 ? 0 : 1)                            }
                        }
                        
                        VStack(spacing: 14) {
                            Spacer()
                            
                            let disableGlobal = isAnyCooldownActive
                            
                            // BUTTON 1: Withdraw 10
                            Button(action: {
                                print("Withdraw 10 clicked")
                                atmVM.withdraw(amount: 10)
                            }, label: {
                                Image("ATM_Button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 17)
                            })
                            .disabled(atmVM.isButtonDisabled(amount: 10) || disableGlobal)
//                            .opacity((atmVM.isButtonDisabled(amount: 10) || disableGlobal) ? 0.5 : 1.0)
                            
                            // BUTTON 2: Withdraw 20
                            Button(action: {
                                print("Withdraw 20 clicked")
                                atmVM.withdraw(amount: 20)
                            }, label: {
                                Image("ATM_Button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 17)
                            })
                            .disabled(atmVM.isButtonDisabled(amount: 20) || disableGlobal)
//                            .opacity((atmVM.isButtonDisabled(amount: 20) || disableGlobal) ? 0.5 : 1.0)
                            
                            // BUTTON 3: Withdraw 10
                            Button(action: {
                                print("Withdraw 50 clicked")
                                atmVM.withdraw(amount: 50)
                            }, label: {
                                Image("ATM_Button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 17)
                            })
                            .disabled(atmVM.isButtonDisabled(amount: 50) || disableGlobal)
//                            .opacity((atmVM.isButtonDisabled(amount: 50) || disableGlobal) ? 0.5 : 1.0)
                            
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
        .disabled(!atmVM.isZoomed)
    }
}
