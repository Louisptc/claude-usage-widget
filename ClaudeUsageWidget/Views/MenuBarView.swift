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

    @State private var showManualEntry = false
    @State private var manualSessionPercent: String = ""
    @State private var manualWeeklyPercent: String = ""

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

                    // Action Buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            onRefreshClick()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(usageMonitor.isLoading)

                        Button(action: {
                            showManualEntry = true
                        }) {
                            Label("From claude.ai", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

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
        .sheet(isPresented: $showManualEntry) {
            ManualUsageEntryView(
                usageMonitor: usageMonitor,
                isPresented: $showManualEntry
            )
        }
    }
}

struct ManualUsageEntryView: View {
    let usageMonitor: UsageMonitor
    @Binding var isPresented: Bool

    @State private var sessionPercent: String = ""
    @State private var weeklyPercent: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Usage from claude.ai")
                .font(.headline)

            Text("Go to claude.ai, click your profile, and check your usage percentages")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Session Usage (%)")
                        .font(.subheadline)
                    TextField("e.g., 32", text: $sessionPercent)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Usage (%)")
                        .font(.subheadline)
                    TextField("e.g., 40", text: $weeklyPercent)
                        .textFieldStyle(.roundedBorder)
                }
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Update") {
                    updateUsage()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(sessionPercent.isEmpty && weeklyPercent.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 280)
    }

    private func updateUsage() {
        var sessionTokens: Int? = nil
        var weeklyTokens: Int? = nil

        if let percent = Double(sessionPercent), percent > 0, percent <= 100 {
            let limit = usageMonitor.currentUsage.sessionUsage.tokensLimit
            sessionTokens = Int(Double(limit) * percent / 100.0)
        }

        if let percent = Double(weeklyPercent), percent > 0, percent <= 100 {
            let limit = usageMonitor.currentUsage.weeklyUsage.tokensLimit
            weeklyTokens = Int(Double(limit) * percent / 100.0)
        }

        usageMonitor.setManualUsage(
            sessionTokens: sessionTokens,
            dailyTokens: nil,
            weeklyTokens: weeklyTokens,
            monthlyTokens: nil
        )
    }
}

#Preview {
    MenuBarView(
        usageMonitor: UsageMonitor(),
        onSettingsClick: {},
        onRefreshClick: {}
    )
}
