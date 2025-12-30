//
//  PermissionPage.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI

struct PermissionPage: View {
    @ObservedObject var permissionManager: PermissionManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(permissionManager.isAccessibilityGranted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: permissionManager.isAccessibilityGranted ? "checkmark.shield.fill" : "lock.shield")
                    .font(.system(size: 44))
                    .foregroundColor(permissionManager.isAccessibilityGranted ? .green : .orange)
            }
            .animation(.spring(), value: permissionManager.isAccessibilityGranted)

            // Title
            Text(permissionManager.isAccessibilityGranted ? "Permission Granted!" : "Enable Accessibility")
                .font(.system(size: 24, weight: .bold))

            // Description
            Text(permissionManager.isAccessibilityGranted
                 ? "Quip can now detect your keyboard shortcuts and expand them automatically."
                 : "Quip needs accessibility permission to detect when you type shortcuts and expand them into full text.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if !permissionManager.isAccessibilityGranted {
                // Grant button
                Button {
                    permissionManager.requestAccessibility()
                } label: {
                    HStack {
                        Image(systemName: "lock.open")
                        Text("Grant Permission")
                    }
                    .frame(minWidth: 180)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Manual link
                Button("Open System Settings manually") {
                    permissionManager.openAccessibilitySettings()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
                // Success indicator
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Ready to continue")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }

            Spacer()

            // Privacy note
            HStack(spacing: 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.caption)
                Text("Quip only monitors keystrokes to detect shortcuts. Nothing is stored or sent anywhere.")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal)
        }
        .padding(32)
        .onAppear {
            _ = permissionManager.checkAccessibility()
        }
    }
}

#Preview {
    PermissionPage(permissionManager: PermissionManager.shared)
        .frame(width: 480, height: 360)
}
