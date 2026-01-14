//
//  UsageData.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import Foundation

struct UsageData: Codable {
    let sessionUsage: SessionUsage
    let dailyUsage: DailyUsage
    let weeklyUsage: WeeklyUsage
    let monthlyUsage: MonthlyUsage
    let lastUpdated: Date

    static var mock: UsageData {
        UsageData(
            sessionUsage: SessionUsage(
                tokensUsed: 8000,
                tokensLimit: 10000,
                requestsUsed: 45,
                requestsLimit: 50
            ),
            dailyUsage: DailyUsage(
                tokensUsed: 150000,
                tokensLimit: 200000,
                resetsAt: Calendar.current.startOfDay(for: Date().addingTimeInterval(24 * 60 * 60))
            ),
            weeklyUsage: WeeklyUsage(
                tokensUsed: 600000,
                tokensLimit: 1000000,
                resetsAt: Date().addingTimeInterval(3 * 24 * 60 * 60)
            ),
            monthlyUsage: MonthlyUsage(
                tokensUsed: 2500000,
                tokensLimit: 5000000,
                resetsAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
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

struct DailyUsage: Codable {
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
        let hours = Int(interval / 3600)

        if hours > 0 {
            return "Resets in \(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "Resets soon"
        }
    }
}

struct MonthlyUsage: Codable {
    let tokensUsed: Int
    let tokensLimit: Int
    let resetsAt: Date

    var percentUsed: Double {
        guard tokensLimit > 0 else { return 0 }
        return Double(tokensUsed) / Double(tokensLimit) * 100
    }

    var formattedUsage: String {
        let usedM = tokensUsed / 1000000
        let limitM = tokensLimit / 1000000
        return "\(usedM)M / \(limitM)M"
    }

    var resetsInText: String {
        let now = Date()
        let interval = resetsAt.timeIntervalSince(now)
        let days = Int(interval / (24 * 60 * 60))

        if days > 0 {
            return "Resets in \(days) day\(days == 1 ? "" : "s")"
        } else {
            return "Resets soon"
        }
    }
}
