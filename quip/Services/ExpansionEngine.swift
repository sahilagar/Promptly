//
//  ExpansionEngine.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import Cocoa
import SwiftData
import Carbon.HIToolbox

class ExpansionEngine {
    static let shared = ExpansionEngine()

    private var expansions: [Expansion] = []
    private var buffer: String = ""
    private let maxBufferSize = 100
    private let queue = DispatchQueue(label: "com.quip.expansion", qos: .userInteractive)

    private init() {}

    func updateExpansions(_ expansions: [Expansion]) {
        queue.async { [weak self] in
            self?.expansions = expansions
        }
    }

    func processKeyEvent(_ character: String, keyCode: UInt16) -> Bool {
        var shouldExpand = false

        queue.sync { [weak self] in
            guard let self = self else { return }

            // Space triggers expansion check
            if character == " " {
                if let expansion = self.checkForMatch() {
                    self.performExpansion(expansion)
                    self.buffer = ""
                    shouldExpand = true
                    return
                }
                self.buffer = ""
                return
            }

            // Backspace removes last character from buffer
            if keyCode == UInt16(kVK_Delete) {
                if !self.buffer.isEmpty {
                    self.buffer.removeLast()
                }
                return
            }

            // Add character to buffer
            self.buffer += character

            // Trim buffer if too long
            if self.buffer.count > self.maxBufferSize {
                self.buffer = String(self.buffer.suffix(self.maxBufferSize))
            }
        }

        return shouldExpand
    }

    private func checkForMatch() -> Expansion? {
        for expansion in expansions {
            if buffer.hasSuffix(expansion.fullTrigger) {
                return expansion
            }
        }
        return nil
    }

    private func performExpansion(_ expansion: Expansion) {
        // Delete the trigger text (including the semicolon)
        let deleteCount = expansion.fullTrigger.count

        DispatchQueue.main.async {
            self.deleteCharacters(count: deleteCount)

            // Small delay to ensure deletions are processed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.typeText(expansion.content)
            }
        }
    }

    private func deleteCharacters(count: Int) {
        let source = CGEventSource(stateID: .hidSystemState)

        for _ in 0..<count {
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Delete), keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Delete), keyDown: false)

            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    private func typeText(_ text: String) {
        let pasteboard = NSPasteboard.general

        // Save previous clipboard contents (both plain and rich text)
        let previousString = pasteboard.string(forType: .string)
        let previousRTF = pasteboard.data(forType: .rtf)

        pasteboard.clearContents()

        // Check if text contains markdown links and convert to rich text
        if let attributedString = convertMarkdownLinks(text), hasMarkdownLinks(text) {
            // Paste as RTF for rich text with links
            if let rtfData = try? attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) {
                pasteboard.setData(rtfData, forType: .rtf)
            }
            // Also set plain text fallback (link text without URLs)
            pasteboard.setString(attributedString.string, forType: .string)
        } else {
            // Plain text paste
            pasteboard.setString(text, forType: .string)
        }

        // Simulate Cmd+V
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        // Restore previous clipboard contents after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            pasteboard.clearContents()
            if let rtf = previousRTF {
                pasteboard.setData(rtf, forType: .rtf)
            }
            if let str = previousString {
                pasteboard.setString(str, forType: .string)
            }
        }
    }

    /// Check if text contains markdown-style links [text](url)
    private func hasMarkdownLinks(_ text: String) -> Bool {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    /// Convert markdown links to NSAttributedString with clickable links
    private func convertMarkdownLinks(_ text: String) -> NSAttributedString? {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let attributedString = NSMutableAttributedString()
        var lastEnd = text.startIndex

        let nsRange = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: nsRange)

        // Default font for the text
        let defaultFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)

        for match in matches {
            // Add text before this match
            if let range = Range(match.range, in: text), range.lowerBound > lastEnd {
                let beforeText = String(text[lastEnd..<range.lowerBound])
                attributedString.append(NSAttributedString(
                    string: beforeText,
                    attributes: [.font: defaultFont]
                ))
            }

            // Extract link text and URL
            if let textRange = Range(match.range(at: 1), in: text),
               let urlRange = Range(match.range(at: 2), in: text) {
                let linkText = String(text[textRange])
                let urlString = String(text[urlRange])

                if let url = URL(string: urlString) {
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .link: url,
                        .font: defaultFont,
                        .foregroundColor: NSColor.linkColor,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ]
                    attributedString.append(NSAttributedString(
                        string: linkText,
                        attributes: linkAttributes
                    ))
                } else {
                    // Invalid URL, just add the text
                    attributedString.append(NSAttributedString(
                        string: linkText,
                        attributes: [.font: defaultFont]
                    ))
                }
            }

            // Update lastEnd
            if let range = Range(match.range, in: text) {
                lastEnd = range.upperBound
            }
        }

        // Add remaining text after last match
        if lastEnd < text.endIndex {
            let remainingText = String(text[lastEnd...])
            attributedString.append(NSAttributedString(
                string: remainingText,
                attributes: [.font: defaultFont]
            ))
        }

        return attributedString
    }

    func clearBuffer() {
        queue.async { [weak self] in
            self?.buffer = ""
        }
    }
}
