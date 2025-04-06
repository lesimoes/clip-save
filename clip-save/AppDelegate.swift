//
//  AppDelegate.swift
//  clip-save
//
//  Created by Leandro Simoes on 05/04/25.
//


import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "App")
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let contentView = ContentView()
        popover.contentSize = NSSize(width: 250, height: 400)
        popover.behavior = .applicationDefined
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showContextMenu()
            return
        }

        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showContextMenu() {
        popover.close()
        let menu = NSMenu()

        let aboutItem = NSMenuItem(title: "About", action: #selector(aboutPopup), keyEquivalent: "")
        aboutItem.target = self;
        menu.addItem(aboutItem)
        
        let exitItem = NSMenuItem(title: "Exit", action: #selector(exitApp), keyEquivalent: "")
        exitItem.target = self
        menu.addItem(exitItem)
        

        if let button = statusItem?.button {
            NSMenu.popUpContextMenu(menu, with: NSApp.currentEvent!, for: button)
        }
    }

    @objc func exitApp() {
        NSApp.terminate(nil)
    }
    
    @objc func aboutPopup() {
        let aboutPopup = NSWindow(
            contentRect: NSRect(x:0, y:0, width: 300, height: 240),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        aboutPopup.center()
        aboutPopup.title = "About"
        aboutPopup.isReleasedWhenClosed = false;
        aboutPopup.contentView = NSHostingView(rootView: AboutView())
        aboutPopup.makeKeyAndOrderFront(nil)
    }
}


