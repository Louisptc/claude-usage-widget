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
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize usage monitor first
        usageMonitor = UsageMonitor()

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gauge.with.dots.needle.50percent", accessibilityDescription: "Claude Usage")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover with usageMonitor
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient

        let menuBarView = MenuBarView(usageMonitor: usageMonitor, onSettingsClick: { [weak self] in
            self?.openSettings()
        }, onRefreshClick: { [weak self] in
            Task {
                await self?.usageMonitor.fetchUsage()
                self?.updateStatusBarIcon()
            }
        })

        popover.contentViewController = NSHostingController(rootView: menuBarView)

        // Start monitoring
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

    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView(usageMonitor: usageMonitor)
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Settings"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
