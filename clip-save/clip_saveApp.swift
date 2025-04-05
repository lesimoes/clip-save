//
//  clip_saveApp.swift
//  clip-save
//
//  Created by Leandro Simoes on 05/04/25.
//

import SwiftUI

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

