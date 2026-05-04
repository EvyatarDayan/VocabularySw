import SwiftUI

class ScoreManager: ObservableObject {
    @Published var correctAnswers: Int = 0
    @Published var wrongAnswers: Int = 0
    @Published var completedTopics: Set<TopicSelectionView.Topic> = []
    @Published var completedCardsByTopic: [TopicSelectionView.Topic: Set<Int>] = [:]
    @Published var cardPositions: [TopicSelectionView.Topic: Int] = [:]
    @Published var savedCardOrders: [TopicSelectionView.Topic: [(String, String)]] = [:]
    @Published private var topicPoints: [TopicSelectionView.Topic: Int] = [:]
    @Published var gameLanguage: LanguageSelectionView.Language?
    
    func reset() {
        correctAnswers = 0
        wrongAnswers = 0
        completedTopics.removeAll()
        completedCardsByTopic.removeAll()
        cardPositions.removeAll()
        savedCardOrders.removeAll()
    }
    
    func markTopicAsCompleted(_ topic: TopicSelectionView.Topic) {
        completedTopics.insert(topic)
    }
    
    func markCardCompleted(_ cardIndex: Int, for topic: TopicSelectionView.Topic) {
        var topicCards = completedCardsByTopic[topic] ?? Set<Int>()
        topicCards.insert(cardIndex)
        completedCardsByTopic[topic] = topicCards
    }
    
    func getCompletedCards(for topic: TopicSelectionView.Topic) -> Set<Int> {
        return completedCardsByTopic[topic] ?? Set<Int>()
    }
    
    func saveCardPosition(_ position: Int, for topic: TopicSelectionView.Topic) {
        cardPositions[topic] = position
    }
    
    func getCardPosition(for topic: TopicSelectionView.Topic) -> Int {
        return cardPositions[topic] ?? 0
    }
    
    func saveCardOrder(_ cards: [(String, String)], for topic: TopicSelectionView.Topic) {
        savedCardOrders[topic] = cards
    }
    
    func getCardOrder(for topic: TopicSelectionView.Topic) -> [(String, String)]? {
        return savedCardOrders[topic]
    }
    
    func addPoints(_ points: Int, for topic: TopicSelectionView.Topic) {
        topicPoints[topic, default: 0] += points
    }
    
    func getTopicPoints(for topic: TopicSelectionView.Topic) -> Int {
        return topicPoints[topic] ?? 0
    }
} 


