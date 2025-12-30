//
//  OnboardingContainer.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI

struct OnboardingContainer: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @StateObject private var permissionManager = PermissionManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)

                PermissionPage(permissionManager: permissionManager)
                    .tag(1)

                DemoPage()
                    .tag(2)
            }
            .tabViewStyle(.automatic)
            .animation(.easeInOut, value: currentPage)

            // Navigation
            HStack {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                // Navigation buttons
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }

                Button(currentPage == 2 ? "Get Started" : "Continue") {
                    handleContinue()
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentPage == 1 && !permissionManager.isAccessibilityGranted)
            }
            .padding(24)
        }
        .frame(width: 480, height: 400)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func handleContinue() {
        if currentPage < 2 {
            withAnimation {
                currentPage += 1
            }
        } else {
            // Complete onboarding
            hasCompletedOnboarding = true

            // Start monitoring now that we have permissions
            if AXIsProcessTrusted() {
                KeyboardMonitor.shared.startMonitoring()
            }

            // Close the onboarding window
            NSApplication.shared.keyWindow?.close()
        }
    }
}

#Preview {
    OnboardingContainer(hasCompletedOnboarding: .constant(false))
}
