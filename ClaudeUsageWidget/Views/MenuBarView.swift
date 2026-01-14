//
//  MenuBarView.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import SwiftUI

struct MenuBarView: View {
    @State private var usageMonitor = UsageMonitor()

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
                VStack(spacing: 20) {
                    // Session Usage
                    UsageSection(
                        title: "Session",
                        icon: "timer",
                        usage: usageMonitor.currentUsage.sessionUsage.percentUsed,
                        subtitle: usageMonitor.currentUsage.sessionUsage.formattedUsage + " tokens"
                    )

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
                        Task {
                            await usageMonitor.fetchUsage()
                        }
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
                    // TODO: Open settings window
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
        .frame(width: 320, height: 400)
    }
}

#Preview {
    MenuBarView()
}
