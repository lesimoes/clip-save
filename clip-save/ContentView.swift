//
//  ContentView.swift
//  clip-save
//
//  Created by Leandro Simoes on 05/04/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct FileShortcut: Identifiable, Equatable {
    let id = UUID()
    let path: String

    var icon: NSImage? {
        NSWorkspace.shared.icon(forFile: path)
    }

    var name: String {
        URL(fileURLWithPath: path).lastPathComponent
    }
}

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var savedTexts: [String] = []
    @State private var shortcuts: [FileShortcut] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SavedTextListView(
                inputText: $inputText,
                savedTexts: $savedTexts,
                onRunCommand: runTerminalCommand
            )

            Spacer()

            ShortcutBarView(shortcuts: $shortcuts, onDrop: handleDrop)
        }
        .padding()
        .frame(width: 250, height: 300)
    }

    func addText() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            savedTexts.insert(trimmed, at: 0)
            inputText = ""
        }
    }

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, _) in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL? {
                        if shortcuts.count < 4 && !shortcuts.contains(where: { $0.path == url.path }) {
                            shortcuts.append(FileShortcut(path: url.path))
                        }
                    }
                }
            }
        }
        return true
    }

    func runTerminalCommand(_ item: String) {
        let prefix = "sh:"
        let command = item.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
        end tell
        delay 0.5
        tell application "System Events"
            keystroke "\(escapedCommand)"
            key code 36
        end tell
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Erro ao executar script: \(error)")
            }
        }
    }
}

