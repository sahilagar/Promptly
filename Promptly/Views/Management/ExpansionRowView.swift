//
//  ExpansionRowView.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI

struct ExpansionRowView: View {
    let expansion: Expansion
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Trigger
            Text(expansion.fullTrigger)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 70, alignment: .leading)

            // Content preview
            Text(expansion.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            // Actions (visible on hover)
            if isHovered {
                HStack(spacing: 4) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red.opacity(0.8))
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Copy to clipboard on tap
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(expansion.content, forType: .string)
        }
    }
}

#Preview {
    VStack {
        ExpansionRowView(
            expansion: Expansion(trigger: "gm", content: "Good morning!"),
            onEdit: {},
            onDelete: {}
        )
        ExpansionRowView(
            expansion: Expansion(trigger: "email", content: "Please feel free to reach out if you have any questions about this matter."),
            onEdit: {},
            onDelete: {}
        )
    }
    .padding()
    .frame(width: 320)
}
