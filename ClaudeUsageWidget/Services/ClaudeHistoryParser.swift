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

    // Rough token estimation (1 token ≈ 4 characters)
    private func estimateTokens(from text: String?) -> Int {
        guard let text = text else { return 0 }
        return text.count / 4
    }

    // Parse history.jsonl file
    func parseHistory() throws -> (sessionTokens: Int, weeklyTokens: Int, turnCount: Int) {
        guard FileManager.default.fileExists(atPath: historyPath.path) else {
            throw NSError(domain: "ClaudeHistory", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "History file not found"
            ])
        }

        let content = try String(contentsOf: historyPath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        let now = Date()
        let weekAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)

        var sessionTokens = 0
        var weeklyTokens = 0
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

            // Count for weekly
            if entryDate > weekAgo {
                weeklyTokens += totalTokens
                turnCount += 1
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

        return (sessionTokens, weeklyTokens, turnCount)
    }
}
