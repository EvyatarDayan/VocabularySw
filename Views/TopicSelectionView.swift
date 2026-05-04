import SwiftUI
import ACarousel
import AVFoundation

struct TopicSelectionView: View {
    let userLanguage: LanguageSelectionView.Language
    @State private var selectedTopic: Topic?
    @State private var isNavigatingToGame = false
    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var scoreManager: ScoreManager
    @ObservedObject var highScoreManager: HighScoreManager
    @State private var showGameCompletionPopup = false
    @State private var showConfetti = false
    @State private var audioPlayer: AVAudioPlayer?
    
//    private var isIPad: Bool {
//        UIDevice.current.userInterfaceIdiom == .pad
//    }
    
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    enum Topic: CaseIterable, Identifiable {
        case animals
        case food
        case FruitAndVegetables
        case colors
        case numbers
        case transportation
        case inTheHouse
        case seasons
        case electric
        case kitchen
        case nature
        case humanBody
        
        
        var id: Self { self }
        
        var imageName: String {
            switch self {
            case .animals: return "TopicAnimals"
            case .food: return "TopicFood"
            case .FruitAndVegetables: return "TopicFruitAndVegetables"
            case .colors: return "TopicColors"
            case .numbers: return "TopicNumbers"
            case .transportation: return "TopicTransportation"
            case .inTheHouse: return "TopicInTheHouse"
            case .seasons: return "TopicSeasons"
            case .electric: return "TopicElectric"
            case .kitchen: return "TopicKitchen"
            case .nature: return "TopicNature"
            case .humanBody: return "TopicHumanBody"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content
            ZStack {
                Image("Sweden5")
                    .resizable()
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    VStack {
                        Text(userLanguage == .english ? "Select a topic" : "בחרו נושא")
//                            .font(isIPhone ? .title2 : .largeTitle)
                            .font(.system(size: isIPhone ? 24 : 50, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            .shadow(radius: 7)
                        
                        ACarousel(Topic.allCases,
                                 index: $currentIndex,
                                 spacing: isIPhone ? geometry.size.width * 0.02 : geometry.size.width * 0.02,
                                 headspace: isIPhone ? geometry.size.width * 0.2 : geometry.size.width * 0.2,
                                 sidesScaling: 1.0,
                                 isWrap: true,
                                 autoScroll: .inactive) { topic in
                            TopicCard(topic: topic,
                                     userLanguage: userLanguage,
                                      cardHeight: isIPhone ? geometry.size.height * 0.55 : geometry.size.height * 0.5,
                                      scoreManager: scoreManager)
                                .scaleEffect(topic == Topic.allCases[currentIndex] ? 1.0 : 0.7)
                                .animation(.easeInOut, value: currentIndex)
                                .onTapGesture {
                                    selectedTopic = topic
                                    if let index = Topic.allCases.firstIndex(of: topic) {
                                        currentIndex = index
                                    }
                                    isNavigatingToGame = true
                                }
                        }
                        .onChange(of: currentIndex) { _ in
                            // Play sound when topic changes
                            if let path = Bundle.main.path(forResource: "topicSelect1", ofType: "mp3") {
                                do {
                                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                                    audioPlayer?.play()
                                } catch {
                                    print("Could not play sound file: \(error)")
                                }
                            }
                        }
                        .frame(height: isIPhone ? 300 : geometry.size.height * 0.7)
                    }
                    .position(x: geometry.size.width/2,
                             y: geometry.size.height * 0.50)
                }
            }
            
            // Overlay home and score buttons
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? 25 : 38)
                        }
                        .foregroundColor(.white)
//                        .frame(width: isIPhone ? 90 : 150, height: isIPhone ? 50 : 70)
                        .frame(
                            width: isIPhone ? 120 : 170,
                            height: isIPhone ? 48 : 65
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 8 : 10)
                        )
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .buttonStyle(NoAnimationButtonStyle())
                    
                    Spacer()
                    
                    ScoreView(scoreManager: scoreManager)
                }
                .padding(.top, 10)
                .padding(.horizontal, 30)
                Spacer()
            }
            
            // Add game completion popup
            if showGameCompletionPopup {
                GameCompletionPopup(
                    userLanguage: userLanguage,
                    scoreManager: scoreManager,
                    highScoreManager: highScoreManager,
                    onAppear: {
                        // Play CompletedGame sound based on language
                        let soundFile = userLanguage == .english ? "CompletedGameEn" : "CompletedGameHe"
                        if let path = Bundle.main.path(forResource: soundFile, ofType: "mp3") {
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                                audioPlayer?.play()
                                
                                // After 2 seconds, show confetti and play applause
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    showConfetti = true
                                    
                                    // Play applause sound
                                    if let applausePath = Bundle.main.path(forResource: "applause", ofType: "mp3") {
                                        do {
                                            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: applausePath))
                                            audioPlayer?.play()
                                        } catch {
                                            print("Could not play applause sound: \(error)")
                                        }
                                    }
                                }
                            } catch {
                                print("Could not play sound file: \(error)")
                            }
                        }
                    },
                    action: {
                        dismiss()
                    }
                )
            }
            
            ConfettiAnimation(isVisible: $showConfetti)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isNavigatingToGame) {
            if let topic = selectedTopic {
                CardGameView(userLanguage: userLanguage, topic: topic, scoreManager: scoreManager)
            }
        }
        .onAppear {
            // Check if all topics are completed
            if scoreManager.completedTopics.count == Topic.allCases.count {
                showGameCompletionPopup = true
            }
        }
    }
}

private var isIPhone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

struct TopicCard: View {
    let topic: TopicSelectionView.Topic
    let userLanguage: LanguageSelectionView.Language
    let cardHeight: CGFloat
    @ObservedObject var scoreManager: ScoreManager
    
    private func getTopicCardCount() -> Int {
        switch topic {
        case .animals: return 24
        case .food: return 22
        case .FruitAndVegetables: return 24
        case .colors: return 12
        case .numbers: return 20
        case .transportation: return 24
        case .inTheHouse: return 24
        case .seasons: return 24
        case .electric: return 21
        case .kitchen: return 21
        case .nature: return 17
        case .humanBody: return 1
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Image(topic.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: cardHeight)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                
                let completedCount = scoreManager.getCompletedCards(for: topic).count
                if completedCount > 0 && !scoreManager.completedTopics.contains(topic) {
                    VStack {
                        Text("\(completedCount)/\(getTopicCardCount())")
                            .font(.system(size: isIPhone ? 22 : 50, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(10)
                        
                            .overlay(
                                RoundedRectangle(cornerRadius: isIPhone ? 8 : 12)
                                    .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 4 : 5)
                            )
                        Spacer()
                    }
                    .padding(.top, isIPhone ? 20 : 40)
                }
                
                if scoreManager.completedTopics.contains(topic) {
                    Image("CompletedTopic")
                        .resizable()
                        .scaledToFit()
                        .frame(height: cardHeight * 0.8)
                        .opacity(0.9)
                        .cornerRadius(15)
                }
            }
            .frame(height: cardHeight)
            
            Text(userLanguage == .english ? englishTopicTitle(for: topic) : hebrewTopicTitle(for: topic))
                .font(.system(size: isIPhone ? 22 : 50, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func englishTopicTitle(for topic: TopicSelectionView.Topic) -> String {
        switch topic {
        case .animals: return "Animals"
        case .food: return "Food"
        case .FruitAndVegetables: return "Fruit And Vegetables"
        case .colors: return "Colors"
        case .numbers: return "Numbers"
        case .transportation: return "Transportation"
        case .inTheHouse: return "In The House"
        case .seasons: return "Seasons"
        case .electric: return "Electric"
        case .kitchen: return "Kitchen"
        case .nature: return "Nature"
        case .humanBody: return "Human Body"
        }
    }
    
    private func hebrewTopicTitle(for topic: TopicSelectionView.Topic) -> String {
        switch topic {
        case .animals: return "חיות"
        case .food: return "אוכל"
        case .FruitAndVegetables: return "פירות וירקות"
        case .colors: return "צבעים"
        case .numbers: return "מספרים"
        case .transportation: return "תחבורה"
        case .inTheHouse: return "בבית"
        case .seasons: return "עונות"
        case .electric: return "מכשירי חשמל"
        case .kitchen: return "במטבח"
        case .nature: return "טבע"
        case .humanBody: return "גוף האדם"
        }
    }
} 
