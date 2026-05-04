import SwiftUI

struct TopicCompletionPopup: View {
    let userLanguage: LanguageSelectionView.Language
    let topic: TopicSelectionView.Topic
    let scoreManager: ScoreManager
    let onAppear: () -> Void
    let action: () -> Void
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(userLanguage == .english ? "Topic completed, well done!" : "הנושא הושלם , יפה מאוד!")
                    .font(.system(size: isIPhone ? 24 : 40, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    HStack {
                        Text(userLanguage == .english 
                            ? "Points: \(scoreManager.getTopicPoints(for: topic))" 
                            : "נקודות: \(scoreManager.getTopicPoints(for: topic))")
                            .font(.system(size: isIPhone ? 20 : 30, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text(userLanguage == .english ? "Mistakes: \(scoreManager.wrongAnswers)" : "פספוסים: \(scoreManager.wrongAnswers)")
                            .font(.system(size: isIPhone ? 20 : 30, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 10)
                
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
        }
    }
} 
