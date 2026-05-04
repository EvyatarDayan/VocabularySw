import Foundation
import SwiftUI

class HighScoreManager: ObservableObject {
    @Published private(set) var highScores: [HighScoreRecord] = []
    private let maxRecords = 10
    private let userDefaults = UserDefaults.standard
    private let storageKey = "highScores"
    
    init() {
        loadHighScores()
    }
    
    func checkAndAddNewScore(score: Int, mistakes: Int) -> Bool {
        let shouldAdd = highScores.count < maxRecords || score > (highScores.last?.score ?? 0)
        return shouldAdd
    }
    
    func addNewRecord(name: String, score: Int, mistakes: Int) {
        let newRecord = HighScoreRecord(name: name, score: score, mistakes: mistakes)
        highScores.append(newRecord)
        highScores.sort { first, second in
            if first.score == second.score {
                return first.mistakes < second.mistakes
            }
            return first.score > second.score
        }
        if highScores.count > maxRecords {
            highScores.removeLast()
        }
        saveHighScores()
    }
    
    private func loadHighScores() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([HighScoreRecord].self, from: data) {
            highScores = decoded
        }
    }
    
    private func saveHighScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }
} 