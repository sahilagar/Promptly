//
//  AppDelegate.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if hasCompletedOnboarding {
            // Start keyboard monitoring if permissions are granted
            if AXIsProcessTrusted() {
                KeyboardMonitor.shared.startMonitoring()
            }
        }
        // Note: Onboarding window is handled by the SwiftUI WindowGroup in quipApp.swift
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyboardMonitor.shared.stopMonitoring()
    }

    // Keep app running when all windows are closed (menu bar app behavior)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
