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

            HStack {
                TextField("Type here...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 100)
                    .onSubmit {
                        addText()
                    }

                Button("Save") {
                    addText()
                }
            }

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(savedTexts, id: \.self) { item in
                        HStack {
                            Text(item)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            
                            if item.lowercased().hasPrefix("sh:") {
                                        Button(action: {
                                            runTerminalCommand(item)
                                        }) {
                                            Image(systemName: "play.circle")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                }
                            
                            
                            Button(action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(item, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Button(action: {
                                if let index = savedTexts.firstIndex(of: item) {
                                    savedTexts.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .padding(.trailing, 4)
            }
            .frame(height: 120)

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text("Drop apps/files here")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(shortcuts) { shortcut in
                        Button(action: {
                            NSWorkspace.shared.open(URL(fileURLWithPath: shortcut.path))
                        }) {
                            if let icon = shortcut.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                shortcuts.removeAll { $0.path == shortcut.path }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }                    }
                }
                .frame(height: 36)
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray.opacity(0.4))
                )
                .onDrop(of: [UTType.fileURL.identifier], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
            }
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
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
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

        // Escapa aspas para evitar quebra de script
        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
        end tell
        delay 3
        tell application "System Events"
            keystroke "\(escapedCommand)"
            key code 36 -- tecla Enter
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

