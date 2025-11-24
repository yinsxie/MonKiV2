//
//  PlayViewModel+Page.swift
//  MonKiV2
//
//  Created by William on 24/11/25.
//

import SwiftUI

extension PlayViewModel {
    
    func getPageIndex(for page: PageIdentifier) -> Int {
        return gamePages.firstIndex(of: page) ?? 0
    }
    
    func getCurrentPage() -> PageIdentifier {
        return gamePages[currentPageIndex ?? 0]
    }
    
    func getPage(at index: Int) -> PageIdentifier {
        return gamePages[index]
    }
    
    func setCurrentIndex(to page: PageIdentifier) {
        currentPageIndex = getPageIndex(for: page)
    }
    
    func navigateTo(withProxy proxy: ScrollViewProxy, page: PageIdentifier) {
        DispatchQueue.main.async {
            proxy.scrollTo(self.getPageIndex(for: page), anchor: .center)
        }
    }
    
    static func getPage(for mode: GameMode) -> [PageIdentifier] {
        var pages: [PageIdentifier] = [
            .ATM
        ]

        switch mode {
        case .singleplayer:
            // Include both shelves for single player
            pages.append(contentsOf: [.shelfA, .shelfB])
            
        case .multiplayer:
            // TODO: Condition on multiplayer
            pages.append(.shelfA)
        }
        
        // Append the remaining pages
        pages.append(contentsOf: [
            .cashierLoading,
            .cashierPayment,
            .createDish
        ])
        
        return pages
    }
}
