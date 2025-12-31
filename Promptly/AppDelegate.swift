//
//  AppDelegate.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        if AXIsProcessTrusted() {
            KeyboardMonitor.shared.startMonitoring()
        } else {
            PermissionManager.shared.requestAccessibility()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyboardMonitor.shared.stopMonitoring()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
