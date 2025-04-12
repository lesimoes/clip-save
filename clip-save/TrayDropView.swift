//
//  TrayDropView.swift
//  clip-save
//
//  Created by Leandro Simoes on 12/04/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

class TrayDropView: NSView {
    var onDropFile: (([URL]) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }

        onDropFile?(items)
        return true
    }
}

