//
//  ExpansionEditSheet.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

struct ExpansionEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Expansion.trigger) private var existingExpansions: [Expansion]
    @ObservedObject private var editorState = EditorState.shared

    @State private var trigger: String = ""
    @State private var content: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showLinkPopover = false
    @State private var linkText: String = ""
    @State private var linkURL: String = ""

    private var expansion: Expansion? { editorState.expansionToEdit }
    var isEditing: Bool { expansion != nil }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isEditing ? "Edit Shortcut" : "New Shortcut")
                    .font(.headline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()

            Divider()

            // Form
            VStack(alignment: .leading, spacing: 20) {
                // Trigger field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Trigger")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 0) {
                        Text(";")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(nsColor: .controlBackgroundColor))

                        TextField("shortcut", text: $trigger)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .onChange(of: trigger) { _, _ in
                                // Clear error when user changes trigger
                                showError = false
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
                }

                // Content field
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Expands to")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Link insertion button
                        Button {
                            showLinkPopover = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                Text("Add Link")
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .popover(isPresented: $showLinkPopover, arrowEdge: .bottom) {
                            linkPopoverContent
                        }
                    }

                    TextEditor(text: $content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .frame(height: 80)
                        .padding(4)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                        )

                    // Hint about link syntax
                    if content.contains("[") && content.contains("](") {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Link detected - will paste as clickable link")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Error message
                if showError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()

            Divider()

            // Actions
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()

                Button(isEditing ? "Save" : "Add") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(trigger.isEmpty || content.isEmpty)
            }
            .padding()
        }
        .frame(width: 360)
        .onAppear {
            if let expansion = expansion {
                trigger = expansion.trigger
                content = expansion.content
            }
        }
    }

    private func save() {
        // Validate
        let cleanTrigger = trigger.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ";", with: "") // Remove any semicolons user might have added

        if cleanTrigger.isEmpty {
            errorMessage = "Trigger cannot be empty"
            showError = true
            return
        }

        // Check for duplicates (unless editing the same expansion)
        let isDuplicate = existingExpansions.contains { existing in
            existing.trigger == cleanTrigger && existing.id != expansion?.id
        }

        if isDuplicate {
            errorMessage = "A shortcut with this trigger already exists"
            showError = true
            return
        }

        if let expansion = expansion {
            // Update existing
            expansion.trigger = cleanTrigger
            expansion.content = content
            expansion.updatedAt = Date()
        } else {
            // Create new
            let newExpansion = Expansion(
                trigger: cleanTrigger,
                content: content
            )
            modelContext.insert(newExpansion)
        }

        dismiss()
    }

    private var linkPopoverContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insert Link")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("Display Text")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("e.g., Book a meeting", text: $linkText)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("e.g., https://calendly.com/you/30min", text: $linkURL)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") {
                    linkText = ""
                    linkURL = ""
                    showLinkPopover = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()

                Button("Insert") {
                    insertLink()
                }
                .buttonStyle(.borderedProminent)
                .disabled(linkText.isEmpty || linkURL.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
    }

    private func insertLink() {
        var url = linkURL.trimmingCharacters(in: .whitespaces)
        // Add https:// if no protocol specified
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "https://" + url
        }

        let markdownLink = "[\(linkText)](\(url))"

        // Append to content (or insert at cursor if we had cursor position)
        if content.isEmpty {
            content = markdownLink
        } else if content.hasSuffix(" ") || content.hasSuffix("\n") {
            content += markdownLink
        } else {
            content += " " + markdownLink
        }

        // Reset and close
        linkText = ""
        linkURL = ""
        showLinkPopover = false
    }
}

#Preview {
    ExpansionEditSheet()
        .modelContainer(for: Expansion.self, inMemory: true)
}
