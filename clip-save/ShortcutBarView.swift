import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ShortcutBarView: View {
    @ObservedObject var storage = ShortcutStorage.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Drop apps/files here")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(storage.shortcuts) { shortcut in
                    Button {
                        NSWorkspace.shared.open(URL(fileURLWithPath: shortcut.path))
                    } label: {
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
                        Button {
                            let fileURL = URL(fileURLWithPath: shortcut.path)
                            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
                        } label: {
                            Label("Open Folder", systemImage: "folder")
                        }
                        Button(role: .destructive) {
                            storage.shortcuts.removeAll { $0 == shortcut }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
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
                providers.forEach { provider in
                    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                        DispatchQueue.main.async {
                            if let data = item as? Data,
                               let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL? {
                                ShortcutStorage.shared.addShortcut(url)
                            }
                        }
                    }
                }
                return true
            }
        }
    }
}
