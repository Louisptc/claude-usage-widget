//
//  ClaudeUsageWidgetApp.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import SwiftUI

@main
struct ClaudeUsageWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
