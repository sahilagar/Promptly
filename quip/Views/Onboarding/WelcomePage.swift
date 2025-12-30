//
//  WelcomePage.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon
            Image(systemName: "text.word.spacing")
                .font(.system(size: 64))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .padding(.bottom, 8)

            // Title
            Text("Welcome to Quip")
                .font(.system(size: 28, weight: .bold))

            // Tagline
            Text("Type less. Say more.")
                .font(.title3)
                .foregroundColor(.secondary)

            // Description
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "keyboard",
                    title: "Quick Shortcuts",
                    description: "Type ;shortcut and press space to expand"
                )

                FeatureRow(
                    icon: "bolt.fill",
                    title: "Instant Expansion",
                    description: "Your text appears instantly, anywhere"
                )

                FeatureRow(
                    icon: "menubar.rectangle",
                    title: "Menu Bar Access",
                    description: "Always one click away"
                )
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(32)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    WelcomePage()
        .frame(width: 480, height: 360)
}
