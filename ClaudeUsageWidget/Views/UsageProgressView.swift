//
//  UsageProgressView.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import SwiftUI

struct UsageSection: View {
    let title: String
    let icon: String
    let usage: Double
    let subtitle: String

    private var progressColor: Color {
        if usage >= 80 {
            return .red
        } else if usage >= 50 {
            return .orange
        } else {
            return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(usage))%")
                    .font(.headline)
                    .foregroundStyle(progressColor)
            }

            ProgressView(value: usage, total: 100)
                .tint(progressColor)
                .frame(height: 8)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UsageSection(
            title: "Session",
            icon: "timer",
            usage: 80,
            subtitle: "8,000 / 10,000 tokens"
        )

        UsageSection(
            title: "Weekly",
            icon: "calendar",
            usage: 60,
            subtitle: "600K / 1M tokens"
        )
    }
    .padding()
}
