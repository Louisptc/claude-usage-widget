//
//  Settings.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import Foundation

class AppSettings: ObservableObject {
    @Published var refreshInterval: TimeInterval = 60 // 1 minute default
    @Published var showNotifications: Bool = true
    @Published var notificationThreshold: Double = 80.0 // Notify at 80% usage

    private let defaults = UserDefaults.standard

    init() {
        loadSettings()
    }

    func loadSettings() {
        refreshInterval = defaults.double(forKey: "refreshInterval")
        if refreshInterval == 0 {
            refreshInterval = 60
        }

        showNotifications = defaults.bool(forKey: "showNotifications")
        notificationThreshold = defaults.double(forKey: "notificationThreshold")
        if notificationThreshold == 0 {
            notificationThreshold = 80.0
        }
    }

    func saveSettings() {
        defaults.set(refreshInterval, forKey: "refreshInterval")
        defaults.set(showNotifications, forKey: "showNotifications")
        defaults.set(notificationThreshold, forKey: "notificationThreshold")
    }
}
