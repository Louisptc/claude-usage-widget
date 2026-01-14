//
//  SettingsView.swift
//  ClaudeUsageWidget
//
//  Settings window for configuring limits
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var usageMonitor: UsageMonitor

    @State private var sessionTokenLimit: String = ""
    @State private var weeklyTokenLimit: String = ""
    @State private var sessionRequestLimit: String = ""
    @State private var refreshInterval: Double = 60

    init(usageMonitor: UsageMonitor) {
        self._usageMonitor = State(initialValue: usageMonitor)
        self.settings = AppSettings()
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            Form {
                Section("Usage Limits") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Token Limit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("200,000", text: $sessionTokenLimit)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly Token Limit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("1,000,000", text: $weeklyTokenLimit)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Request Limit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("50", text: $sessionRequestLimit)
                            .textFieldStyle(.roundedBorder)
                    }

                    Text("These are the maximum limits. Actual usage is estimated from your history.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Monitoring") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Refresh Interval")
                            Spacer()
                            Text("\(Int(refreshInterval))s")
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $refreshInterval, in: 30...300, step: 30)
                    }

                    Toggle("Show Notifications", isOn: $settings.showNotifications)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Notification Threshold")
                            Spacer()
                            Text("\(Int(settings.notificationThreshold))%")
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $settings.notificationThreshold, in: 50...95, step: 5)
                    }
                    .disabled(!settings.showNotifications)
                }
            }
            .formStyle(.grouped)

            HStack(spacing: 12) {
                Button("Reset to Defaults") {
                    sessionTokenLimit = "200000"
                    weeklyTokenLimit = "1000000"
                    sessionRequestLimit = "50"
                    refreshInterval = 60
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Save") {
                    saveSettings()
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 450, height: 500)
        .onAppear {
            loadCurrentSettings()
        }
    }

    private func loadCurrentSettings() {
        let defaults = UserDefaults.standard

        let sessionLimit = defaults.integer(forKey: "sessionTokenLimit")
        sessionTokenLimit = sessionLimit > 0 ? "\(sessionLimit)" : "200000"

        let weeklyLimit = defaults.integer(forKey: "weeklyTokenLimit")
        weeklyTokenLimit = weeklyLimit > 0 ? "\(weeklyLimit)" : "1000000"

        let requestLimit = defaults.integer(forKey: "sessionRequestLimit")
        sessionRequestLimit = requestLimit > 0 ? "\(requestLimit)" : "50"

        refreshInterval = settings.refreshInterval
    }

    private func saveSettings() {
        // Save limits
        if let limit = Int(sessionTokenLimit.replacingOccurrences(of: ",", with: "")) {
            usageMonitor.setSessionLimit(limit)
        }

        if let limit = Int(weeklyTokenLimit.replacingOccurrences(of: ",", with: "")) {
            usageMonitor.setWeeklyLimit(limit)
        }

        if let limit = Int(sessionRequestLimit) {
            usageMonitor.setSessionRequestLimit(limit)
        }

        // Save app settings
        settings.refreshInterval = refreshInterval
        settings.saveSettings()
    }
}

#Preview {
    SettingsView(usageMonitor: UsageMonitor())
}
