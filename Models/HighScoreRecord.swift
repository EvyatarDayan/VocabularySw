import Foundation

struct HighScoreRecord: Codable, Identifiable {
    let id: String
    let name: String
    let score: Int
    let mistakes: Int
    let timestamp: TimeInterval
    
    init(name: String, score: Int, mistakes: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.score = score
        self.mistakes = mistakes
        self.timestamp = Date().timeIntervalSince1970
    }
} 