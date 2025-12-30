//
//  quipApp.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import SwiftUI
import SwiftData

@main
struct quipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expansion.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Menu bar app
        MenuBarExtra {
            MenuBarContentView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .modelContainer(sharedModelContainer)
        } label: {
            Image(systemName: "text.word.spacing")
        }
        .menuBarExtraStyle(.window)

        // Onboarding window
        Window("Welcome to Quip", id: "onboarding") {
            OnboardingContainer(hasCompletedOnboarding: $hasCompletedOnboarding)
                .modelContainer(sharedModelContainer)
                .onDisappear {
                    // Seed demo data after onboarding
                    if hasCompletedOnboarding {
                        seedDemoDataIfNeeded()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    private func seedDemoDataIfNeeded() {
        let context = sharedModelContainer.mainContext
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
            print("Failed to seed demo data: \(error)")
        }
    }
}
