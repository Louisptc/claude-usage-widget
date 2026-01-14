//
//  ClaudeHistoryParser.swift
//  ClaudeUsageWidget
//
//  Parse Claude Code history to estimate usage
//

import Foundation

struct HistoryEntry: Codable {
    let timestamp: Double
    let model: String?
    let inputText: String?
    let outputText: String?

    enum CodingKeys: String, CodingKey {
        case timestamp, model
        case inputText = "input_text"
        case outputText = "output_text"
    }
}

class ClaudeHistoryParser {
    private let historyPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude")
        .appendingPathComponent("history.jsonl")

    // Rough token estimation (1 token ≈ 6-7 characters for mixed content)
    // This is adjustable - real ratio varies between 4-8 depending on language/code
    private func estimateTokens(from text: String?) -> Int {
        guard let text = text else { return 0 }
        // Get user-configured ratio or use default
        let defaults = UserDefaults.standard
        let ratio = defaults.integer(forKey: "tokenEstimationRatio")
        let finalRatio = ratio > 0 ? ratio : 7
        return text.count / finalRatio
    }

    // Parse history.jsonl file
    func parseHistory() throws -> (sessionTokens: Int, dailyTokens: Int, weeklyTokens: Int, monthlyTokens: Int, turnCount: Int) {
        guard FileManager.default.fileExists(atPath: historyPath.path) else {
            throw NSError(domain: "ClaudeHistory", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "History file not found"
            ])
        }

        let content = try String(contentsOf: historyPath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        let now = Date()
        let dayAgo = now.addingTimeInterval(-24 * 60 * 60)
        let weekAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)
        let monthAgo = now.addingTimeInterval(-30 * 24 * 60 * 60)

        var sessionTokens = 0
        var dailyTokens = 0
        var weeklyTokens = 0
        var monthlyTokens = 0
        var turnCount = 0
        var lastSessionStart: Date?

        for line in lines {
            guard let data = line.data(using: .utf8),
                  let entry = try? JSONDecoder().decode(HistoryEntry.self, from: data) else {
                continue
            }

            let entryDate = Date(timeIntervalSince1970: entry.timestamp / 1000)

            // Estimate tokens
            let inputTokens = estimateTokens(from: entry.inputText)
            let outputTokens = estimateTokens(from: entry.outputText)
            let totalTokens = inputTokens + outputTokens

            // Count for daily
            if entryDate > dayAgo {
                dailyTokens += totalTokens
            }

            // Count for weekly
            if entryDate > weekAgo {
                weeklyTokens += totalTokens
                turnCount += 1
            }

            // Count for monthly
            if entryDate > monthAgo {
                monthlyTokens += totalTokens
            }

            // Session detection: entries within 30 minutes are same session
            if lastSessionStart == nil || entryDate.timeIntervalSince(lastSessionStart!) > 30 * 60 {
                lastSessionStart = entryDate
                sessionTokens = 0 // Reset session counter
            }

            // Only count current session (last continuous conversation)
            if entryDate > now.addingTimeInterval(-30 * 60) {
                sessionTokens += totalTokens
            }
        }

        return (sessionTokens, dailyTokens, weeklyTokens, monthlyTokens, turnCount)
    }
}
