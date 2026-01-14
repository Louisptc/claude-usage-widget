//
//  AppDelegate.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var usageMonitor: UsageMonitor!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gauge.with.dots.needle.50percent", accessibilityDescription: "Claude Usage")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())

        // Initialize usage monitor
        usageMonitor = UsageMonitor()
        usageMonitor.startMonitoring()

        // Update status bar icon based on usage
        updateStatusBarIcon()
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private func updateStatusBarIcon() {
        // Update icon color based on usage percentage
        // This will be called periodically by UsageMonitor
        guard let button = statusItem.button else { return }

        let usage = usageMonitor.currentUsage
        let weeklyPercent = usage.weeklyUsage.percentUsed

        let iconName: String
        if weeklyPercent >= 80 {
            iconName = "gauge.with.dots.needle.100percent"
        } else if weeklyPercent >= 50 {
            iconName = "gauge.with.dots.needle.67percent"
        } else {
            iconName = "gauge.with.dots.needle.33percent"
        }

        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Claude Usage")
    }
}
