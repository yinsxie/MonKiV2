//
//  PlayViewModel+Notification.swift
//  MonKiV2
//
//  Created by William on 30/11/25.
//

import Foundation
import SwiftUI

@MainActor
extension PlayViewModel {
    
    /// Shows a notification, interrupting any existing one.
    func show(_ type: NotificationType) {
        // Cancel any pending auto-hide task.
        dismissNotificationTask?.cancel()
        
        // If a notification is already visible, hide it quickly, then show the new one.
        if isNotificationVisible {
            hideNotification(duration: 0.1) {
                self.displayNotification(type)
            }
        } else {
            // Otherwise, just display the new notification.
            displayNotification(type)
        }
    }
    
    /// Displays the notification view and schedules its dismissal.
    private func displayNotification(_ type: NotificationType) {
        currentNotification = type
        
        withAnimation(.easeOut(duration: 0.3)) {
            isNotificationVisible = true
        }
        
        // Schedule an auto-hide task.
        dismissNotificationTask = Task {
            do {
                // Wait for 3 seconds.
                try await Task.sleep(for: .seconds(3))
                // If the task hasn't been cancelled, hide the notification.
                if !Task.isCancelled {
                    hideNotification()
                }
            } catch {
                // Task was cancelled, so we do nothing.
            }
        }
    }
    
    /// Hides the currently visible notification.
    func hideNotification(duration: TimeInterval = 0.25, completion: (() -> Void)? = nil) {
        withAnimation(.easeIn(duration: duration)) {
            isNotificationVisible = false
        }
        
        // After the hide animation, clear the notification content.
        Task {
            try? await Task.sleep(for: .seconds(duration))
            if !isNotificationVisible { // Only clear if it's still hidden
                self.currentNotification = nil
            }
            completion?()
        }
    }
    
    /// Called when the user manually dismisses a notification (e.g., via drag).
    func userDismiss() {
        dismissNotificationTask?.cancel()
        hideNotification()
    }
}
