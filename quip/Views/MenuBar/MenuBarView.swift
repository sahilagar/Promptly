//
//  MenuBarView.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

/// Wrapper view that handles onboarding window opening
struct MenuBarContentView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.openWindow) private var openWindow
    @State private var hasCheckedOnboarding = false

    var body: some View {
        MenuBarView()
            .task {
                // Only check once per app session
                guard !hasCheckedOnboarding else { return }
                hasCheckedOnboarding = true

                if !hasCompletedOnboarding {
                    openWindow(id: "onboarding")
                }
            }
    }
}

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expansion.trigger) private var expansions: [Expansion]

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var editingExpansion: Expansion?
    @State private var isEnabled = true

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
            // Header
            header

            Divider()

            // Search
            searchBar

            // Expansion list
            if filteredExpansions.isEmpty {
                emptyState
            } else {
                expansionList
            }

            Divider()

            // Footer
            footer
        }
        .frame(width: 320, height: 400)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingAddSheet) {
            ExpansionEditSheet(expansion: nil)
        }
        .sheet(item: $editingExpansion) { expansion in
            ExpansionEditSheet(expansion: expansion)
        }
        .onAppear {
            // Update expansion engine with current expansions
            ExpansionEngine.shared.updateExpansions(expansions)
        }
        .onChange(of: expansions) { _, newValue in
            ExpansionEngine.shared.updateExpansions(newValue)
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "text.word.spacing")
                .foregroundColor(.accentColor)

            Text("Quip")
                .font(.headline)

            Spacer()

            // Enable/disable toggle
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
                        onEdit: { editingExpansion = expansion },
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
                showingAddSheet = true
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
