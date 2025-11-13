//
//  StartingPageView.swift
//  MonKiV2
//
//  Created by William on 13/11/25.
//

import SwiftUI

struct StartingPageView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Starting Page")
            
            Button {
                appCoordinator.goTo(.play(.play))
            } label: {
                Text("Solo Play")
            }
            
            Button {
                
            } label: {
                Text("Duo Play")
            }
            
        }
    }
}

#Preview {
    StartingPageView()
}
