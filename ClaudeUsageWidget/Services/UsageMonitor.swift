//
//  UsageMonitor.swift
//  ClaudeUsageWidget
//
//  Created by Claude Code
//

import Foundation
import Combine

@Observable
class UsageMonitor {
    var currentUsage: UsageData
    var isLoading: Bool = false
    var errorMessage: String?

    private var timer: Timer?
    private let settings = AppSettings()
    private let historyParser = ClaudeHistoryParser()
    private let defaults = UserDefaults.standard

    init() {
        // Load saved usage or start with defaults
        if let data = defaults.data(forKey: "lastUsageData"),
           let usage = try? JSONDecoder().decode(UsageData.self, from: data) {
            self.currentUsage = usage
        } else {
            self.currentUsage = UsageData.mock
        }
    }

    func startMonitoring() {
        // Initial fetch
        Task {
            await fetchUsage()
        }

        // Set up timer for periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: settings.refreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchUsage()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    @MainActor
    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            let usage = try await readClaudeUsageData()
            currentUsage = usage
            saveUsage(usage)
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to fetch usage: \(error)")
        }

        isLoading = false
    }

    private func readClaudeUsageData() async throws -> UsageData {
        // Parse history file on background thread
        return try await Task.detached {
            let parser = ClaudeHistoryParser()
            let (sessionTokens, dailyTokens, weeklyTokens, monthlyTokens, turnCount) = try parser.parseHistory()

            // Get user-configured limits or use defaults
            let sessionLimit = self.defaults.integer(forKey: "sessionTokenLimit")
            let dailyLimit = self.defaults.integer(forKey: "dailyTokenLimit")
            let weeklyLimit = self.defaults.integer(forKey: "weeklyTokenLimit")
            let monthlyLimit = self.defaults.integer(forKey: "monthlyTokenLimit")
            let sessionRequestLimit = self.defaults.integer(forKey: "sessionRequestLimit")

            // Use defaults if not configured
            let finalSessionLimit = sessionLimit > 0 ? sessionLimit : 200000
            let finalDailyLimit = dailyLimit > 0 ? dailyLimit : 500000
            let finalWeeklyLimit = weeklyLimit > 0 ? weeklyLimit : 2000000
            let finalMonthlyLimit = monthlyLimit > 0 ? monthlyLimit : 10000000
            let finalRequestLimit = sessionRequestLimit > 0 ? sessionRequestLimit : 50

            // Calculate reset times
            let calendar = Calendar.current
            let now = Date()

            // Daily reset: next midnight
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now

            // Weekly reset: next Monday 00:00 UTC
            var weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            weekComponents.weekday = 2 // Monday
            weekComponents.hour = 0
            weekComponents.minute = 0
            weekComponents.second = 0

            let thisMonday = calendar.date(from: weekComponents) ?? now
            let nextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: thisMonday) ?? now
            let weeklyResetsAt = now > thisMonday ? nextMonday : thisMonday

            // Monthly reset: first day of next month
            var monthComponents = calendar.dateComponents([.year, .month], from: now)
            monthComponents.day = 1
            monthComponents.hour = 0
            monthComponents.minute = 0
            monthComponents.second = 0

            let thisMonthStart = calendar.date(from: monthComponents) ?? now
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: thisMonthStart) ?? now

            return UsageData(
                sessionUsage: SessionUsage(
                    tokensUsed: sessionTokens,
                    tokensLimit: finalSessionLimit,
                    requestsUsed: min(turnCount, finalRequestLimit),
                    requestsLimit: finalRequestLimit
                ),
                dailyUsage: DailyUsage(
                    tokensUsed: dailyTokens,
                    tokensLimit: finalDailyLimit,
                    resetsAt: tomorrow
                ),
                weeklyUsage: WeeklyUsage(
                    tokensUsed: weeklyTokens,
                    tokensLimit: finalWeeklyLimit,
                    resetsAt: weeklyResetsAt
                ),
                monthlyUsage: MonthlyUsage(
                    tokensUsed: monthlyTokens,
                    tokensLimit: finalMonthlyLimit,
                    resetsAt: nextMonthStart
                ),
                lastUpdated: Date()
            )
        }.value
    }

    // MARK: - Persistence

    private func saveUsage(_ usage: UsageData) {
        if let encoded = try? JSONEncoder().encode(usage) {
            defaults.set(encoded, forKey: "lastUsageData")
        }
    }

    // MARK: - Manual Adjustments

    func setSessionLimit(_ limit: Int) {
        defaults.set(limit, forKey: "sessionTokenLimit")
        Task {
            await fetchUsage()
        }
    }

    func setDailyLimit(_ limit: Int) {
        defaults.set(limit, forKey: "dailyTokenLimit")
        Task {
            await fetchUsage()
        }
    }

    func setWeeklyLimit(_ limit: Int) {
        defaults.set(limit, forKey: "weeklyTokenLimit")
        Task {
            await fetchUsage()
        }
    }

    func setMonthlyLimit(_ limit: Int) {
        defaults.set(limit, forKey: "monthlyTokenLimit")
        Task {
            await fetchUsage()
        }
    }

    func setSessionRequestLimit(_ limit: Int) {
        defaults.set(limit, forKey: "sessionRequestLimit")
        Task {
            await fetchUsage()
        }
    }

    // Manual override for actual usage (if user knows from claude.ai)
    func setManualUsage(sessionTokens: Int?, dailyTokens: Int?, weeklyTokens: Int?, monthlyTokens: Int?) {
        var updated = currentUsage

        if let sessionTokens = sessionTokens {
            updated = UsageData(
                sessionUsage: SessionUsage(
                    tokensUsed: sessionTokens,
                    tokensLimit: updated.sessionUsage.tokensLimit,
                    requestsUsed: updated.sessionUsage.requestsUsed,
                    requestsLimit: updated.sessionUsage.requestsLimit
                ),
                dailyUsage: updated.dailyUsage,
                weeklyUsage: updated.weeklyUsage,
                monthlyUsage: updated.monthlyUsage,
                lastUpdated: Date()
            )
        }

        if let dailyTokens = dailyTokens {
            updated = UsageData(
                sessionUsage: updated.sessionUsage,
                dailyUsage: DailyUsage(
                    tokensUsed: dailyTokens,
                    tokensLimit: updated.dailyUsage.tokensLimit,
                    resetsAt: updated.dailyUsage.resetsAt
                ),
                weeklyUsage: updated.weeklyUsage,
                monthlyUsage: updated.monthlyUsage,
                lastUpdated: Date()
            )
        }

        if let weeklyTokens = weeklyTokens {
            updated = UsageData(
                sessionUsage: updated.sessionUsage,
                dailyUsage: updated.dailyUsage,
                weeklyUsage: WeeklyUsage(
                    tokensUsed: weeklyTokens,
                    tokensLimit: updated.weeklyUsage.tokensLimit,
                    resetsAt: updated.weeklyUsage.resetsAt
                ),
                monthlyUsage: updated.monthlyUsage,
                lastUpdated: Date()
            )
        }

        if let monthlyTokens = monthlyTokens {
            updated = UsageData(
                sessionUsage: updated.sessionUsage,
                dailyUsage: updated.dailyUsage,
                weeklyUsage: updated.weeklyUsage,
                monthlyUsage: MonthlyUsage(
                    tokensUsed: monthlyTokens,
                    tokensLimit: updated.monthlyUsage.tokensLimit,
                    resetsAt: updated.monthlyUsage.resetsAt
                ),
                lastUpdated: Date()
            )
        }

        currentUsage = updated
        saveUsage(updated)
    }
}
