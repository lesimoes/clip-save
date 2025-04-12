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
                onRunCommand: runTerminalCommand,
                openWeb: openWeb
            )

            Spacer()

            ShortcutBarView()
        }
        .padding()
        .frame(width: 250, height: 320)
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
    
    func openWeb(_ item: String) {
        var urlString = item.trimmingCharacters(in: .whitespacesAndNewlines)

            if urlString.lowercased().hasPrefix("web:") {
                urlString = String(urlString.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                urlString = "https://" + urlString
            }

            guard let url = URL(string: urlString), NSWorkspace.shared.open(url) else {
                print("Erro: Invalid URL - \(urlString)")
                return
            }
        
    }

    func runTerminalCommand(_ item: String) {
        guard item.lowercased().hasPrefix("sh:") else { return }

           let command = item.dropFirst(3).trimmingCharacters(in: .whitespacesAndNewlines)
               .replacingOccurrences(of: "\"", with: "\\\"") // escapa aspas

           let appleScript = """
           tell application "Terminal"
               if not running then launch
               activate
           end tell

           delay 0.8

           tell application "System Events"
               keystroke "\(command)"
               key code 36
           end tell
           """

           let process = Process()
           process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
           process.arguments = ["-e", appleScript]

           do {
               try process.run()
           } catch {
               print("Erro ao executar AppleScript: \(error)")
           }
    
    }
}

