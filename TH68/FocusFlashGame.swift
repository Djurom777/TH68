//
//  FocusFlashGame.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct FocusFlashGame: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameData: GameData
    @State private var gameState: FocusGameState = .instruction
    @State private var currentTarget = ""
    @State private var options: [String] = []
    @State private var score = 0
    @State private var level = 1
    @State private var timeRemaining = 3.0
    @State private var timer: Timer?
    @State private var isCorrect = false
    
    private let shapes = ["circle", "square", "triangle", "diamond", "star"]
    private let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    private let maxLevel = 15
    
    enum FocusGameState {
        case instruction, playing, result, complete
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Focus Flash")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(.white)
            
            switch gameState {
            case .instruction:
                instructionView
            case .playing:
                gameView
            case .result:
                resultView
            case .complete:
                completionView
            }
        }
        .padding()
        .onAppear {
            startNewLevel()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 20) {
            Text("Tap the correct shape or number before time runs out")
                .font(.title2)
                .foregroundColor(.lightGray)
                .multilineTextAlignment(.center)
            
            Text("Level \(level)")
                .font(.title.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            Button("Start") {
                startRound()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 30) {
            // Timer
            Text(String(format: "%.1f", timeRemaining))
                .font(.title.weight(.bold))
                
                .foregroundColor(timeRemaining < 1 ? .crimsonPink : .white)
            
            // Target
            Text("Find: \(currentTarget)")
                .font(.title2)
                
                .foregroundColor(.neonGreen)
            
            // Options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        handleSelection(option)
                    }) {
                        if level <= 5 {
                            Image(systemName: getSystemName(for: option))
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        } else {
                            Text(option)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Text(isCorrect ? "Correct!" : "Time's Up!")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(isCorrect ? .neonGreen : .crimsonPink)
            
            if isCorrect {
                Text("Level \(level) Complete!")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Button("Continue") {
                if isCorrect {
                    // Сохраняем статистику после каждого успешного уровня
                    let levelScore = level * 15
                    score += levelScore
                    gameData.addScore(levelScore, for: .focusFlash)
                    gameData.addReward(.flameOfFocus)
                    
                    if level < maxLevel {
                        level += 1
                        startNewLevel()
                    } else {
                        gameState = .complete
                    }
                } else if !isCorrect && level > 1 {
                    startNewLevel()
                } else {
                    gameState = .complete
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("Amazing Focus!")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white)
            
            Image(systemName: RewardType.flameOfFocus.icon)
                .font(.system(size: 60))
                .foregroundColor(RewardType.flameOfFocus.color)
            
            Text("You earned: \(RewardType.flameOfFocus.rawValue)")
                .font(.headline.weight(.bold))
                .foregroundColor(.lightGray)
            
            Button("Done") {
                // Статистика уже сохранена в resultView
                isPresented = false
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .onAppear {
            // Статистика уже сохранена в resultView
        }
    }
    
    private func startNewLevel() {
        gameState = .instruction
    }
    
    private func startRound() {
        gameState = .playing
        timeRemaining = max(2.0, 5.0 - Double(level) * 0.2)
        
        // Generate target and options
        if level <= 5 {
            // Shape mode
            currentTarget = shapes.randomElement()!
            options = Array(shapes.shuffled().prefix(6))
            if !options.contains(currentTarget) {
                options[0] = currentTarget
            }
        } else {
            // Number mode
            currentTarget = numbers.randomElement()!
            options = Array(numbers.shuffled().prefix(9))
            if !options.contains(currentTarget) {
                options[0] = currentTarget
            }
        }
        options.shuffle()
        
        // Start timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timer?.invalidate()
                isCorrect = false
                gameState = .result
            }
        }
    }
    
    private func handleSelection(_ selection: String) {
        timer?.invalidate()
        isCorrect = selection == currentTarget
        gameState = .result
    }
    
    private func getSystemName(for shape: String) -> String {
        switch shape {
        case "circle": return "circle"
        case "square": return "square"
        case "triangle": return "triangle"
        case "diamond": return "diamond"
        case "star": return "star"
        default: return "questionmark"
        }
    }
}
