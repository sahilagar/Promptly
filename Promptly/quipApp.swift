//
//  PromptlyApp.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

@main
struct PromptlyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expansion.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            seedDemoDataIfNeeded(in: container)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        } label: {
            Image(systemName: "text.word.spacing")
        }
        .menuBarExtraStyle(.window)

        Window("Edit Shortcut", id: "edit-expansion") {
            ExpansionEditSheet()
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

private func seedDemoDataIfNeeded(in container: ModelContainer) {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<Expansion>()

    do {
        let count = try context.fetchCount(descriptor)
        if count == 0 {
            for demo in Expansion.demoExpansions {
                context.insert(demo)
            }
            try context.save()
        }
    } catch {
        // Silently fail - demo data is not critical
    }
}
