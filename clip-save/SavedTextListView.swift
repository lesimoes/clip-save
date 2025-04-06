import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SavedTextListView: View {
    
    @Binding var inputText: String
    @Binding var savedTexts: [String]
    var onRunCommand: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Type here...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                                Button {
                                    onRunCommand(item)
                                } label: {
                                    Image(systemName: "play.circle")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }

                            Button {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(item, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Button {
                                savedTexts.removeAll { $0 == item }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .padding(.trailing, 4)
            }
            .frame(height: 120)
        }
    }

    func addText() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            savedTexts.insert(trimmed, at: 0)
            inputText = ""
        }
    }
}
