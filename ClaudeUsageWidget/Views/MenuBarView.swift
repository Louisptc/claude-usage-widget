//
//  MenuBarView.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import SwiftUI

struct MenuBarView: View {
    @Bindable var usageMonitor: UsageMonitor
    let onSettingsClick: () -> Void
    let onRefreshClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "brain.fill")
                    .foregroundStyle(.blue)
                Text("Claude Usage")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Session Usage
                    UsageSection(
                        title: "Session",
                        icon: "timer",
                        usage: usageMonitor.currentUsage.sessionUsage.percentUsed,
                        subtitle: usageMonitor.currentUsage.sessionUsage.formattedUsage + " tokens"
                    )

                    Divider()

                    // Daily Usage
                    UsageSection(
                        title: "Daily",
                        icon: "sun.max",
                        usage: usageMonitor.currentUsage.dailyUsage.percentUsed,
                        subtitle: usageMonitor.currentUsage.dailyUsage.formattedUsage + " tokens"
                    )

                    Text(usageMonitor.currentUsage.dailyUsage.resetsInText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Weekly Usage
                    UsageSection(
                        title: "Weekly",
                        icon: "calendar",
                        usage: usageMonitor.currentUsage.weeklyUsage.percentUsed,
                        subtitle: usageMonitor.currentUsage.weeklyUsage.formattedUsage + " tokens"
                    )

                    Text(usageMonitor.currentUsage.weeklyUsage.resetsInText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Monthly Usage
                    UsageSection(
                        title: "Monthly",
                        icon: "calendar.circle",
                        usage: usageMonitor.currentUsage.monthlyUsage.percentUsed,
                        subtitle: usageMonitor.currentUsage.monthlyUsage.formattedUsage + " tokens"
                    )

                    Text(usageMonitor.currentUsage.monthlyUsage.resetsInText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Last Updated
                    HStack {
                        Text("Last updated:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(usageMonitor.currentUsage.lastUpdated, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Refresh Button
                    Button(action: {
                        onRefreshClick()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(usageMonitor.isLoading)

                    if let error = usageMonitor.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Button("Settings") {
                    onSettingsClick()
                }
                .buttonStyle(.link)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 320, height: 550)
    }
}

#Preview {
    MenuBarView(
        usageMonitor: UsageMonitor(),
        onSettingsClick: {},
        onRefreshClick: {}
    )
}
