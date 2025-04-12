//
//  ShortcutStorage.swift
//  clip-save
//
//  Created by Leandro Simoes on 12/04/25.
//

import Foundation
import SwiftUI

class ShortcutStorage: ObservableObject {
    static let shared = ShortcutStorage()
    
    @Published var shortcuts: [FileShortcut] = []
    
    func addShortcut(_ url: URL) {
        let shortcut = FileShortcut(path: url.path)
        if !shortcuts.contains(shortcut) && shortcuts.count < 4 {
            shortcuts.append(shortcut)
        }
    }
}
