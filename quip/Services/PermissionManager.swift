//
//  PermissionManager.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import Cocoa
import Combine

@MainActor
class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published var isAccessibilityGranted: Bool = false

    private var timer: Timer?

    private init() {
        checkAccessibility()
    }

    func checkAccessibility() -> Bool {
        let granted = AXIsProcessTrusted()
        isAccessibilityGranted = granted
        return granted
    }

    func requestAccessibility() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]
        AXIsProcessTrustedWithOptions(options)
        startPollingForPermission()
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        startPollingForPermission()
    }

    func startPollingForPermission() {
        stopPollingForPermission()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.checkAccessibility() {
                    self.stopPollingForPermission()
                }
            }
        }
    }

    func stopPollingForPermission() {
        timer?.invalidate()
        timer = nil
    }
}
