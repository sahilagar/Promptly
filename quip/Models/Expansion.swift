//
//  Expansion.swift
//  quip
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import SwiftData

@Model
final class Expansion: Identifiable {
    @Attribute(.unique) var id: UUID
    var trigger: String
    var content: String
    var category: String?
    var createdAt: Date
    var updatedAt: Date

    var fullTrigger: String {
        ";\(trigger)"
    }

    init(trigger: String, content: String, category: String? = nil) {
        self.id = UUID()
        self.trigger = trigger
        self.content = content
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    static var demoExpansions: [Expansion] {
        [
            Expansion(trigger: "gm", content: "Good morning!", category: "Greetings"),
            Expansion(trigger: "ty", content: "Thank you so much, I really appreciate it.", category: "Greetings"),
            Expansion(trigger: "email", content: "Please feel free to reach out if you have any questions.", category: "Professional")
        ]
    }
}
