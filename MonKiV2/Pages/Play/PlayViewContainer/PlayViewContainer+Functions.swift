//
//  PlayViewContainer+Functions.swift
//  MonKiV2
//
//  Created by William on 24/11/25.
//

import SwiftUI

// MARK: - Helper Logic functions
internal extension PlayViewContainer {
    func handlePageChange(_ newIndex: Int?) {
        guard playVM.atmVM.isZoomed else { return }
        
        if let index = newIndex, playVM.getPage(at: index) != .ATM {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                playVM.atmVM.isZoomed = false
            }
        }
    }
    
    func handleFrameUpdates(_ frames: [String: CGRect]) {
        DispatchQueue.main.async {
            if let atm = frames["ATM"], self.playVM.atmFrame != atm {
                self.playVM.atmFrame = atm
            }
            if let wallet = frames["WALLET"], self.playVM.walletFrame != wallet {
                self.playVM.walletFrame = wallet
            }
        }
    }
    
    func toggleIntroButton(index: Int?) {
        if let index = index, playVM.getPage(at: index) != .createDish {
            playVM.isIntroButtonVisible = false
        }
    }
    
    func handleGameOnAppear(_ proxy: ScrollViewProxy) {
        // Set the initial index to the last page (pages.count-1)
        playVM.setCurrentIndex(to: .createDish)
        // Force jump to the last page using ScrollViewReader's proxy
        playVM.navigateTo(withProxy: proxy, page: .createDish)
    }
    
    func handleOnWalletIdle() {
        if playVM.walletVM.isWalletOpen {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                playVM.walletVM.isWalletOpen = false
            }
        }
    }
    
    func toggleInactivityMonitoring(on newIndex: Int?) {
        let pagesWithIdleTutorial: [PageIdentifier] = [.shelfA]
        if let index = newIndex, pagesWithIdleTutorial.contains(playVM.gamePages[index]) {
            inactivityManager.startMonitoring()
        } else {
            inactivityManager.stopMonitoring()
        }
    }
}
