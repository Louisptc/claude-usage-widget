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

    init() {
        // Start with mock data
        self.currentUsage = UsageData.mock
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
            // Try to read from Claude Code's local files
            let usage = try await readClaudeUsageData()
            currentUsage = usage
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to fetch usage: \(error)")
        }

        isLoading = false
    }

    private func readClaudeUsageData() async throws -> UsageData {
        // TODO: Implement actual reading from Claude Code files
        // For now, return mock data with some randomization

        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay to simulate fetch

        // Generate slightly randomized mock data
        let sessionTokens = Int.random(in: 7000...9000)
        let weeklyTokens = Int.random(in: 500000...700000)

        return UsageData(
            sessionUsage: SessionUsage(
                tokensUsed: sessionTokens,
                tokensLimit: 10000,
                requestsUsed: Int.random(in: 40...50),
                requestsLimit: 50
            ),
            weeklyUsage: WeeklyUsage(
                tokensUsed: weeklyTokens,
                tokensLimit: 1000000,
                resetsAt: Date().addingTimeInterval(TimeInterval.random(in: 2*24*3600...4*24*3600))
            ),
            lastUpdated: Date()
        )
    }
}
