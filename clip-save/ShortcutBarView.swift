import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ShortcutBarView: View {
    @Binding var shortcuts: [FileShortcut]
    var onDrop: ([NSItemProvider]) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Drop apps/files here")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(shortcuts) { shortcut in
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
                        Button(role: .destructive) {
                            shortcuts.removeAll { $0 == shortcut }
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
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: nil, perform: onDrop)
        }
    }
}

