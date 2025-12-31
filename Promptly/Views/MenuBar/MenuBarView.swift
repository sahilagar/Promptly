//
//  MenuBarView.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \Expansion.trigger) private var expansions: [Expansion]

    @State private var searchText = ""
    @State private var isEnabled = true
    @ObservedObject private var permissionManager = PermissionManager.shared

    var filteredExpansions: [Expansion] {
        if searchText.isEmpty {
            return expansions
        }
        return expansions.filter {
            $0.trigger.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !permissionManager.isAccessibilityGranted {
                permissionBanner
            }

            header

            Divider()

            searchBar

            if filteredExpansions.isEmpty {
                emptyState
            } else {
                expansionList
            }

            Divider()

            footer
        }
        .frame(width: 320, height: permissionManager.isAccessibilityGranted ? 400 : 440)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            _ = permissionManager.checkAccessibility()
            ExpansionEngine.shared.updateExpansions(expansions)
        }
        .onChange(of: expansions) { _, newValue in
            ExpansionEngine.shared.updateExpansions(newValue)
        }
    }

    private var permissionBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Accessibility required")
                .font(.caption)
            Spacer()
            Button("Enable") {
                permissionManager.openAccessibilitySettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(10)
        .background(Color.orange.opacity(0.15))
    }

    private var header: some View {
        HStack {
            Image(systemName: "text.word.spacing")
                .foregroundColor(.accentColor)

            Text("Promptly")
                .font(.headline)

            Spacer()

            HStack(spacing: 6) {
                Text(isEnabled ? "On" : "Off")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .onChange(of: isEnabled) { _, newValue in
                        if newValue {
                            KeyboardMonitor.shared.startMonitoring()
                        } else {
                            KeyboardMonitor.shared.stopMonitoring()
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search shortcuts...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var expansionList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(filteredExpansions) { expansion in
                    ExpansionRowView(
                        expansion: expansion,
                        onEdit: {
                            EditorState.shared.editExpansion(expansion)
                            NSApplication.shared.activate(ignoringOtherApps: true)
                            openWindow(id: "edit-expansion")
                        },
                        onDelete: { deleteExpansion(expansion) }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: searchText.isEmpty ? "keyboard" : "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.5))

            Text(searchText.isEmpty ? "No shortcuts yet" : "No matches found")
                .font(.headline)
                .foregroundColor(.secondary)

            if searchText.isEmpty {
                Text("Tap + to create your first shortcut")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        HStack {
            Button {
                EditorState.shared.createNew()
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "edit-expansion")
            } label: {
                Label("Add New", systemImage: "plus")
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func deleteExpansion(_ expansion: Expansion) {
        withAnimation {
            modelContext.delete(expansion)
        }
    }
}

#Preview {
    MenuBarView()
        .modelContainer(for: Expansion.self, inMemory: true)
}
