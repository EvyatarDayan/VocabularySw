import SwiftUI

struct GameCompletionPopup: View {
    let userLanguage: LanguageSelectionView.Language
    let scoreManager: ScoreManager
    let highScoreManager: HighScoreManager
    let onAppear: () -> Void
    let action: () -> Void
    
    @State private var showNameInput = false
    @State private var playerName = ""
    
    private var totalScore: Int {
        TopicSelectionView.Topic.allCases.reduce(0) { $0 + scoreManager.getTopicPoints(for: $1) }
    }
    
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(userLanguage == .english ? "Game completed, well done!" : "המשחק הושלם, יפה מאוד!")
                    .font(.system(size: isIPhone ? 24 : 40, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    HStack {
                        Text(userLanguage == .english 
                            ? "Total Points: \(TopicSelectionView.Topic.allCases.reduce(0) { $0 + scoreManager.getTopicPoints(for: $1) })" 
                            : "סך הכל נקודות: \(TopicSelectionView.Topic.allCases.reduce(0) { $0 + scoreManager.getTopicPoints(for: $1) })")
                            .font(.system(size: isIPhone ? 20 : 30, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text(userLanguage == .english ? "Total Mistakes: \(scoreManager.wrongAnswers)" : "סך הכל פספוסים: \(scoreManager.wrongAnswers)")
                            .font(.system(size: isIPhone ? 20 : 30, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)
                
                // Add name input if qualifies for high score
                if showNameInput {
                    VStack(spacing: 10) {
                        Text(userLanguage == .english ? "New High Score!" : "שיא חדש!")
                            .font(.system(size: isIPhone ? 20 : 32, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text(userLanguage == .english ? "Enter your name:" : "הכנס את שמך:")
                            .font(.system(size: isIPhone ? 18 : 28))
                        
                        TextField("", text: $playerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: isIPhone ? 200 : 300)
                            .font(.system(size: isIPhone ? 18 : 28))
                            .multilineTextAlignment(.center)
                            .onChange(of: playerName) { newValue in
                                if newValue.count > 12 {
                                    playerName = String(newValue.prefix(12))
                                }
                            }
                        
                        Button(action: {
                            if !playerName.isEmpty {
                                highScoreManager.addNewRecord(
                                    name: playerName,
                                    score: totalScore,
                                    mistakes: scoreManager.wrongAnswers
                                )
                            }
                            action()
                        }) {
                            Text(userLanguage == .english ? "Save" : "שמור")
                                .font(.system(size: isIPhone ? 18 : 28, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: isIPhone ? 120 : 200, height: isIPhone ? 40 : 60)
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 3 : 5)
                                )
                        }
                    }
//                    .padding(.vertical)
                } else {
                    Button(action: action) {
                        HStack(spacing: 20) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? 25 : 38)
                            Text(userLanguage == .english ? "Back" : "חזרה")
                                .font(.system(size: isIPhone ? 18 : 30, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: isIPhone ? 200 : 300, height: isIPhone ? 50 : 70)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 3 : 5)
                        )
                    }
                }
            }
            .buttonStyle(NoAnimationButtonStyle())
            .padding(30)
            .background(Color.white.opacity(0.9))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 5)
            )
            .padding(.horizontal, 40)
        }
        .onAppear {
            onAppear()
            if highScoreManager.checkAndAddNewScore(score: totalScore, mistakes: scoreManager.wrongAnswers) {
                showNameInput = true
            }
        }
    }
} 
