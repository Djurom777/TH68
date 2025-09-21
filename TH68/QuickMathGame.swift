//
//  QuickMathGame.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct QuickMathGame: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameData: GameData
    @State private var gameState: MathGameState = .instruction
    @State private var currentEquation = ""
    @State private var correctAnswer = 0
    @State private var options: [Int] = []
    @State private var score = 0
    @State private var level = 1
    @State private var timeRemaining = 5.0
    @State private var timer: Timer?
    @State private var isCorrect = false
    @State private var questionsCompleted = 0
    
    private let maxLevel = 20
    private let questionsPerLevel = 5
    
    enum MathGameState {
        case instruction, playing, result, complete
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Quick Math")
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
            Text("Solve rapid-fire simple equations under time pressure")
                .font(.title2)
                .foregroundColor(.lightGray)
                .multilineTextAlignment(.center)
            
            Text("Level \(level)")
                .font(.title.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            Text("\(questionsPerLevel) questions to complete")
                .font(.headline.weight(.bold))
                .foregroundColor(.lightGray)
            
            Button("Start") {
                startRound()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 30) {
            // Progress and Timer
            HStack {
                Text("\(questionsCompleted)/\(questionsPerLevel)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.lightGray)
                
                Spacer()
                
                Text(String(format: "%.1f", timeRemaining))
                    .font(.title.weight(.bold))
                    
                    .foregroundColor(timeRemaining < 2 ? .crimsonPink : .white)
            }
            
            // Equation
            Text(currentEquation)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.neonGreen)
            
            // Options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        handleSelection(option)
                    }) {
                        Text("\(option)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Text(isCorrect ? "Correct!" : "Time's Up!")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(isCorrect ? .neonGreen : .crimsonPink)
            
            if questionsCompleted >= questionsPerLevel {
                Text("Level \(level) Complete!")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button("Next Level") {
                    // Сохраняем статистику после каждого успешного уровня
                    let levelScore = level * 20
                    score += levelScore
                    gameData.addScore(levelScore, for: .quickMath)
                    gameData.addReward(.starOfSpeed)
                    
                    if level < maxLevel {
                        level += 1
                        questionsCompleted = 0
                        startNewLevel()
                    } else {
                        gameState = .complete
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button("Continue") {
                    startRound()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("Math Genius!")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white)
            
            Image(systemName: RewardType.starOfSpeed.icon)
                .font(.system(size: 60))
                .foregroundColor(RewardType.starOfSpeed.color)
            
            Text("You earned: \(RewardType.starOfSpeed.rawValue)")
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
        questionsCompleted = 0
    }
    
    private func startRound() {
        gameState = .playing
        timeRemaining = max(3.0, 6.0 - Double(level) * 0.2)
        generateEquation()
        
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
    
    private func generateEquation() {
        let a = Int.random(in: 1...(5 + level))
        let b = Int.random(in: 1...(5 + level))
        let operation = Int.random(in: 0...1)
        
        if operation == 0 {
            // Addition
            currentEquation = "\(a) + \(b) = ?"
            correctAnswer = a + b
        } else {
            // Multiplication
            let smallA = Int.random(in: 1...min(12, 3 + level))
            let smallB = Int.random(in: 1...min(12, 3 + level))
            currentEquation = "\(smallA) × \(smallB) = ?"
            correctAnswer = smallA * smallB
        }
        
        // Generate options
        options = [correctAnswer]
        while options.count < 4 {
            let wrongAnswer = correctAnswer + Int.random(in: -10...10)
            if wrongAnswer != correctAnswer && wrongAnswer > 0 && !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }
        options.shuffle()
    }
    
    private func handleSelection(_ selection: Int) {
        timer?.invalidate()
        isCorrect = selection == correctAnswer
        
        if isCorrect {
            score += level * 5
            questionsCompleted += 1
        }
        
        gameState = .result
    }
}
