//
//  AboutView.swift
//  clip-save
//
//  Created by Leandro Simoes on 06/04/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AboutView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Clipsave")
                .font(.title2)
                .bold()
            Text("Version 1.0.1")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("A simple free and open source app to save snippets, file and apps")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
            Text("Created by lesimoes")
                .font(.subheadline)
                .bold()
            Link("Source code", destination: URL(string: "https://github.com/lesimoes/clip-save")!)
                .font(.footnote)
        }
        .padding()
        .frame(width: 280, height: 160)
        
    }
}
