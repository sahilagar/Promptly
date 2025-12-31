//
//  ExpansionListView.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

struct ExpansionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \Expansion.trigger) private var expansions: [Expansion]

    @State private var searchText = ""

    var groupedExpansions: [(String, [Expansion])] {
        let filtered = searchText.isEmpty
            ? expansions
            : expansions.filter {
                $0.trigger.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }

        let grouped = Dictionary(grouping: filtered) { $0.category ?? "Uncategorized" }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding()

            // List
            if groupedExpansions.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No shortcuts")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(groupedExpansions, id: \.0) { category, items in
                        Section(header: Text(category)) {
                            ForEach(items) { expansion in
                                ExpansionRowView(
                                    expansion: expansion,
                                    onEdit: {
                                        EditorState.shared.editExpansion(expansion)
                                        openWindow(id: "edit-expansion")
                                    },
                                    onDelete: { deleteExpansion(expansion) }
                                )
                            }
                        }
                    }
                }
            }

            // Add button
            HStack {
                Spacer()
                Button {
                    EditorState.shared.createNew()
                    openWindow(id: "edit-expansion")
                } label: {
                    Label("Add Shortcut", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func deleteExpansion(_ expansion: Expansion) {
        withAnimation {
            modelContext.delete(expansion)
        }
    }
}

#Preview {
    ExpansionListView()
        .modelContainer(for: Expansion.self, inMemory: true)
}
