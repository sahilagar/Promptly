//
//  DemoPage.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI

struct DemoPage: View {
    @State private var demoExpansions = Expansion.demoExpansions

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.linearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            // Title
            Text("You're All Set!")
                .font(.system(size: 24, weight: .bold))

            // Description
            Text("We've added a few example shortcuts to get you started. Try them out or create your own!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Demo expansions
            VStack(spacing: 12) {
                ForEach(demoExpansions, id: \.trigger) { expansion in
                    DemoExpansionRow(expansion: expansion)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .padding(.horizontal, 32)

            // Hint
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Type")
                Text(";gm")
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Text("and press space to try it!")
            }
            .font(.callout)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(32)
    }
}

struct DemoExpansionRow: View {
    let expansion: Expansion

    var body: some View {
        HStack {
            Text(expansion.fullTrigger)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 60, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(expansion.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
    }
}

#Preview {
    DemoPage()
        .frame(width: 480, height: 360)
}
