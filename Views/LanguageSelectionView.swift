import SwiftUI
import AVFoundation

struct LanguageSelectionView: View {
    @StateObject private var scoreManager = ScoreManager()
    @StateObject private var highScoreManager = HighScoreManager()
    @State private var showHighScores = false
    @State private var showNewGameAlert = false
    @State private var selectedLanguage: Language?
    @State private var isNavigatingToTopics = false
    @State private var showCustomAlert = false
    @State private var showHebrew = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var audioPlayer: AVAudioPlayer?
    
    enum Language {
        case english
        case hebrew
    }
    
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    private var flagBaseSize: CGFloat {
        isIPhone ? 60 : 120  // Base size - adjust this number to scale both flags
    }
    
    private var flagWidth: CGFloat { flagBaseSize * 2.5 }  // 200/80 = 2.5
    private var flagHeight: CGFloat { flagBaseSize * 1.5 } // 120/80 = 1.5
    
    private var isGameInProgress: Bool {
        !scoreManager.completedCardsByTopic.isEmpty
    }
    
    private var shouldShowContinueButton: Bool {
        isGameInProgress && 
        scoreManager.completedTopics.count < TopicSelectionView.Topic.allCases.count &&
        selectedLanguage == scoreManager.gameLanguage  // Only show if languages match
    }
    
    private var buttonText: String {
        if isGameInProgress {
            return selectedLanguage == .hebrew 
                ? "משחק חדש"
                : (selectedLanguage == .english ? "New game" : "Nytt spel")
        } else if selectedLanguage != nil {
            return selectedLanguage == .hebrew 
                ? "התחילו"
                : (selectedLanguage == .english ? "Start" : "Select")
        } else {
            return showHebrew ? "בחרו" : "Select"
        }
    }
    
    private var titleText: String {
        if selectedLanguage == nil {
            return showHebrew ? "משחקים ולומדים שוודית" : "Play and Learn Swedish"
        } else {
            return selectedLanguage == .hebrew ? "משחקים ולומדים שוודית" : "Play and Learn Swedish"
        }
    }
    
    private func playTrophySound() {
        if let path = Bundle.main.path(forResource: "highScore1", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not play sound file: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Sweden4")
                    .resizable()
//                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                if !showHighScores {  // Only play sound when opening
                                    playTrophySound()
                                    showHighScores = true  // Only allow opening, not closing
                                }
                            }
                        }) {
                            Image("Trophy1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? 40 : 60)
                        }
                        .buttonStyle(NoAnimationButtonStyle())
                        .disabled(showHighScores)
                        .padding(.top, isIPhone ? 40 : 20)
                        .padding(.trailing, isIPhone ? -10 : 30)
                    }
                    Spacer()
                }
                
                VStack(spacing: isIPhone ? -45 : 30) {
                    Text(titleText)
                    // This is the language view title font
                        .font(.system(size: isIPhone ? 45 : 90))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
//                        .shadow(color: .black, radius: 8)
                        .shadow(color: .black, radius: 8)
                        .shadow(radius: 7)
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            selectedLanguage = .english
                        }) {
                            VStack {
                                ZStack {
                                    if selectedLanguage == .english {
                                        RoundedRectangle(cornerRadius: isIPhone ? 10 : 15)
                                            .stroke(Color.green, lineWidth: isIPhone ? 4 : 10)
                                            .frame(width: flagWidth, height: flagHeight)
                                    }
                                    
                                    Image("USAFlag")
                                        .resizable()
    //                                    .scaledToFit()
                                        .frame(width: flagWidth, height: flagHeight)
                                        .cornerRadius(isIPhone ? 10 : 25)
                                        .shadow(radius: 5)
                                }
                                
                                Text("English")
                                    .font(.system(size: isIPhone ? 25 : 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 8)
                                    .shadow(color: .black, radius: 8)
                                    .shadow(radius: 7)
                            }
                        }
                        .buttonStyle(NoAnimationButtonStyle())
                        .padding()
                        
                        Button(action: {
                            selectedLanguage = .hebrew
                        }) {
                            VStack {
                                ZStack {
                                    if selectedLanguage == .hebrew {
                                        RoundedRectangle(cornerRadius: isIPhone ? 10 : 15)
                                            .stroke(Color.green, lineWidth: isIPhone ? 4 : 10)
                                            .frame(width: flagWidth, height: flagHeight)
                                    }
                                    
                                    Image("IsraelFlag")
                                        .resizable()
    //                                    .scaledToFit()
                                        .frame(width: flagWidth, height: flagHeight)
                                        .cornerRadius(isIPhone ? 10 : 25)
                                        .shadow(radius: 5)
                                }
                                
                                Text("עברית")
                                    .font(.system(size: isIPhone ? 25 : 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 8)
                                    .shadow(color: .black, radius: 8)
                                    .shadow(radius: 7)
                            }
                        }
                        .buttonStyle(NoAnimationButtonStyle())
                        .padding()
                    }
                    
                    // Game buttons container
                    HStack(spacing: 240) {
                        // Start New Game Button
                        Button(action: {
                            if isGameInProgress {
                                showCustomAlert = true
                            } else {
                                scoreManager.reset()
                                scoreManager.gameLanguage = selectedLanguage  // Store the language
                                isNavigatingToTopics = true
                            }
                        }) {
                            Text(buttonText)
                                .font(.system(size: isIPhone ? 22 : 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: isIPhone ? 180 : 300, height: isIPhone ? 60 : 80)
                                .background(selectedLanguage != nil ? Color.blue.opacity(0.9) : Color.gray.opacity(0.7))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 4 : 8)
                                )
                        }
                        .buttonStyle(NoAnimationButtonStyle())
                        .disabled(selectedLanguage == nil)
                        .onReceive(timer) { _ in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showHebrew.toggle()
                            }
                        }
                        
                        // Continue Game Button (only show if game in progress)
                        if shouldShowContinueButton {
                            NavigationLink(destination: TopicSelectionView(
                                userLanguage: selectedLanguage ?? .english, 
                                scoreManager: scoreManager,
                                highScoreManager: highScoreManager
                            )) {
                                Text(selectedLanguage == .hebrew 
                                    ? "המשך"
                                    : (selectedLanguage == .english ? "Continue" : "Fortsätt spela"))
                                    .font(.system(size: isIPhone ? 22 : 40, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: isIPhone ? 180 : 300, height: isIPhone ? 60 : 80)
                                    .background(Color.green.opacity(0.9))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 4 : 8)
                                    )
                            }
                            .buttonStyle(NoAnimationButtonStyle())
                        }
                    }
                    .padding(.top, 50)
                }
                .disabled(showHighScores)
                
                if showCustomAlert {
                    CustomLanguageAlert(
                        userLanguage: selectedLanguage ?? .english,
                        onConfirm: {
                            scoreManager.reset()
                            scoreManager.gameLanguage = selectedLanguage  // Set the new language
                            showCustomAlert = false
                            isNavigatingToTopics = true  // Navigate directly to topics
                        },
                        onCancel: {
                            showCustomAlert = false
                        }
                    )
                }
                
                if showHighScores {
                    HighScoreView(
                        userLanguage: selectedLanguage ?? .english,
                        highScoreManager: highScoreManager,
                        isPresented: $showHighScores
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: showHighScores)
                }
            }
            .navigationDestination(isPresented: $isNavigatingToTopics) {
                if let language = selectedLanguage {
                    TopicSelectionView(
                        userLanguage: language, 
                        scoreManager: scoreManager,
                        highScoreManager: highScoreManager
                    )
                }
            }
        }
    }
}

struct CustomLanguageAlert: View {
    let userLanguage: LanguageSelectionView.Language
    let onConfirm: () -> Void
    let onCancel: () -> Void
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(userLanguage == .english ? "Start new game?" : "להתחיל משחק חדש?")
                    .font(.system(size: isIPhone ? 24 : 40, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(userLanguage == .english ? "This will reset all scores" : "כל הנקודות ימחקו")
                    .font(.system(size: isIPhone ? 20 : 30))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                HStack(spacing: 20) {
                    Button(action: onCancel) {
                        Text(userLanguage == .english ? "Cancel" : "ביטול")
                            .font(.system(size: isIPhone ? 18 : 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: isIPhone ? 120 : 200, height: isIPhone ? 50 : 70)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 3 : 5)
                            )
                    }
                    
                    Button(action: onConfirm) {
                        Text(userLanguage == .english ? "Start new" : "התחילו חדש")
                            .font(.system(size: isIPhone ? 18 : 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: isIPhone ? 120 : 200, height: isIPhone ? 50 : 70)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 3 : 5)
                            )
                    }
                }
            }
            .padding(30)
            .background(Color.white.opacity(0.9))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 5)
            )
            .padding(.horizontal, 40)
        }
    }
}

struct NoAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(nil, value: configuration.isPressed)  // Explicitly disable animation
    }
} 
