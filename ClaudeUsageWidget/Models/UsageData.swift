//
//  UsageData.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import Foundation

struct UsageData: Codable {
    let sessionUsage: SessionUsage
    let weeklyUsage: WeeklyUsage
    let lastUpdated: Date

    static var mock: UsageData {
        UsageData(
            sessionUsage: SessionUsage(
                tokensUsed: 8000,
                tokensLimit: 10000,
                requestsUsed: 45,
                requestsLimit: 50
            ),
            weeklyUsage: WeeklyUsage(
                tokensUsed: 600000,
                tokensLimit: 1000000,
                resetsAt: Date().addingTimeInterval(3 * 24 * 60 * 60)
            ),
            lastUpdated: Date()
        )
    }
}

struct SessionUsage: Codable {
    let tokensUsed: Int
    let tokensLimit: Int
    let requestsUsed: Int
    let requestsLimit: Int

    var percentUsed: Double {
        guard tokensLimit > 0 else { return 0 }
        return Double(tokensUsed) / Double(tokensLimit) * 100
    }

    var formattedUsage: String {
        "\(tokensUsed.formatted()) / \(tokensLimit.formatted())"
    }
}

struct WeeklyUsage: Codable {
    let tokensUsed: Int
    let tokensLimit: Int
    let resetsAt: Date

    var percentUsed: Double {
        guard tokensLimit > 0 else { return 0 }
        return Double(tokensUsed) / Double(tokensLimit) * 100
    }

    var formattedUsage: String {
        let usedK = tokensUsed / 1000
        let limitK = tokensLimit / 1000
        return "\(usedK)K / \(limitK)K"
    }

    var resetsInText: String {
        let now = Date()
        let interval = resetsAt.timeIntervalSince(now)
        let days = Int(interval / (24 * 60 * 60))
        let hours = Int((interval.truncatingRemainder(dividingBy: 24 * 60 * 60)) / 3600)

        if days > 0 {
            return "Resets in \(days) day\(days == 1 ? "" : "s")"
        } else if hours > 0 {
            return "Resets in \(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "Resets soon"
        }
    }
}
