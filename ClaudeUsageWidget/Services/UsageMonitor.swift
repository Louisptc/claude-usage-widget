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
            let (sessionTokens, weeklyTokens, turnCount) = try parser.parseHistory()

            // Get user-configured limits or use defaults
            let sessionLimit = self.defaults.integer(forKey: "sessionTokenLimit")
            let weeklyLimit = self.defaults.integer(forKey: "weeklyTokenLimit")
            let sessionRequestLimit = self.defaults.integer(forKey: "sessionRequestLimit")

            // Use defaults if not configured
            let finalSessionLimit = sessionLimit > 0 ? sessionLimit : 200000
            let finalWeeklyLimit = weeklyLimit > 0 ? weeklyLimit : 1000000
            let finalRequestLimit = sessionRequestLimit > 0 ? sessionRequestLimit : 50

            // Calculate weekly reset (assuming Monday 00:00 UTC)
            let calendar = Calendar.current
            let now = Date()
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekday = 2 // Monday
            components.hour = 0
            components.minute = 0
            components.second = 0

            let thisMonday = calendar.date(from: components) ?? now
            let nextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: thisMonday) ?? now

            let resetsAt = now > thisMonday ? nextMonday : thisMonday

            return UsageData(
                sessionUsage: SessionUsage(
                    tokensUsed: sessionTokens,
                    tokensLimit: finalSessionLimit,
                    requestsUsed: min(turnCount, finalRequestLimit),
                    requestsLimit: finalRequestLimit
                ),
                weeklyUsage: WeeklyUsage(
                    tokensUsed: weeklyTokens,
                    tokensLimit: finalWeeklyLimit,
                    resetsAt: resetsAt
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

    func setWeeklyLimit(_ limit: Int) {
        defaults.set(limit, forKey: "weeklyTokenLimit")
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
    func setManualUsage(sessionTokens: Int?, weeklyTokens: Int?) {
        var updated = currentUsage

        if let sessionTokens = sessionTokens {
            updated = UsageData(
                sessionUsage: SessionUsage(
                    tokensUsed: sessionTokens,
                    tokensLimit: updated.sessionUsage.tokensLimit,
                    requestsUsed: updated.sessionUsage.requestsUsed,
                    requestsLimit: updated.sessionUsage.requestsLimit
                ),
                weeklyUsage: updated.weeklyUsage,
                lastUpdated: Date()
            )
        }

        if let weeklyTokens = weeklyTokens {
            updated = UsageData(
                sessionUsage: updated.sessionUsage,
                weeklyUsage: WeeklyUsage(
                    tokensUsed: weeklyTokens,
                    tokensLimit: updated.weeklyUsage.tokensLimit,
                    resetsAt: updated.weeklyUsage.resetsAt
                ),
                lastUpdated: Date()
            )
        }

        currentUsage = updated
        saveUsage(updated)
    }
}
