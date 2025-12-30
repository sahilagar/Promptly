//
//  KeyboardMonitor.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import Cocoa
import Carbon.HIToolbox

class KeyboardMonitor {
    static let shared = KeyboardMonitor()

    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isMonitoring = false

    private init() {}

    func startMonitoring() {
        guard !isMonitoring else { return }
        guard AXIsProcessTrusted() else {
            print("Accessibility permission not granted")
            return
        }

        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: keyboardCallback,
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            isMonitoring = true
            print("Keyboard monitoring started")
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isMonitoring = false
        print("Keyboard monitoring stopped")
    }
}

private func keyboardCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // Handle tap disabled events (system can disable taps)
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = KeyboardMonitor.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    guard type == .keyDown else {
        return Unmanaged.passUnretained(event)
    }

    guard let nsEvent = NSEvent(cgEvent: event) else {
        return Unmanaged.passUnretained(event)
    }

    let keyCode = nsEvent.keyCode
    let characters = nsEvent.characters ?? ""

    // Process the key event
    _ = ExpansionEngine.shared.processKeyEvent(characters, keyCode: keyCode)

    return Unmanaged.passUnretained(event)
}
