//
//  EditorState.swift
//  Promptly
//
//  Created by Sahil Agarwal on 12/30/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EditorState: ObservableObject {
    static let shared = EditorState()

    @Published var expansionToEdit: Expansion?

    private init() {}

    func editExpansion(_ expansion: Expansion) {
        expansionToEdit = expansion
    }

    func createNew() {
        expansionToEdit = nil
    }

    func clear() {
        expansionToEdit = nil
    }
}
