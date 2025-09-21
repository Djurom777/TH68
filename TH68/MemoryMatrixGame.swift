//
//  MemoryMatrixGame.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct MemoryMatrixGame: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameData: GameData
    @State private var gameState: MemoryGameState = .instruction
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var showingTiles = false
    @State private var currentTileIndex = 0
    @State private var score = 0
    @State private var level = 1
    
    private let gridSize = 4
    private let maxLevel = 10
    
    enum MemoryGameState {
        case instruction, showing, input, result, complete
    }
    
    var body: some View {
        ZStack {
            Color.darkGraphite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Memory Matrix")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                
                switch gameState {
                case .instruction:
                    instructionView
                case .showing, .input:
                    gameGridView
                case .result:
                    resultView
                case .complete:
                    completionView
                }
            }
            .padding()
        }
        .onAppear {
            print("🚀 MemoryMatrixGame appeared - gameData scores: \(gameData.scores)")
            print("🚀 MemoryMatrixGame appeared - gameData rewards: \(gameData.rewards)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startNewLevel()
            }
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 20) {
            Text("Watch the tiles light up, then reproduce the sequence")
                .font(.title2)
                .foregroundColor(.lightGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Level \(level)")
                .font(.title.weight(.bold))
                .foregroundColor(.neonGreen)
            
            Button("Start") {
                gameState = .showing
                showSequence()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var gameGridView: some View {
        VStack(spacing: 20) {
            Text(gameState == .showing ? "Watch carefully..." : "Tap the tiles in order")
                .font(.title3)
                .foregroundColor(.lightGray)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 10) {
                ForEach(0..<gridSize*gridSize, id: \.self) { index in
                    Rectangle()
                        .fill(tileColor(for: index))
                        .frame(height: 60)
                        .cornerRadius(8)
                        .onTapGesture {
                            if gameState == .input {
                                handleTileTap(index)
                            }
                        }
                        .scaleEffect(sequence.contains(index) && showingTiles ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: showingTiles)
                }
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Text(userSequence == sequence ? "Perfect!" : "Try Again")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(userSequence == sequence ? .neonGreen : .crimsonPink)
            
            if userSequence == sequence {
                Text("Level \(level) Complete!")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Button("Continue") {
                if userSequence == sequence {
                    // Сохраняем статистику после каждого успешного уровня
                    let levelScore = level * 10
                    score += levelScore
                    gameData.addScore(levelScore, for: .memoryMatrix)
                    gameData.addReward(.crystalOfMemory)
                    
                    if level < maxLevel {
                        level += 1
                        startNewLevel()
                    } else {
                        gameState = .complete
                    }
                } else {
                    startNewLevel()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("Great Memory!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.neonGreen)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white)
            
            Image(systemName: RewardType.crystalOfMemory.icon)
                .font(.system(size: 60))
                .foregroundColor(RewardType.crystalOfMemory.color)
            
            Text("You earned: \(RewardType.crystalOfMemory.rawValue)")
                .font(.headline)
                .foregroundColor(.lightGray)
            
            Button("Done") {
                // Статистика уже сохранена в resultView
                isPresented = false
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .onAppear {
            // Статистика уже сохранена в resultView, здесь не дублируем
        }
    }
    
    private func tileColor(for index: Int) -> Color {
        if gameState == .showing && index == currentTileIndex && showingTiles {
            return .neonGreen
        } else if gameState == .input && userSequence.contains(index) {
            return .crimsonPink
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func startNewLevel() {
        // Генерируем уникальную последовательность без повторений
        let sequenceLength = min(2 + level, gridSize * gridSize)
        var availableIndices = Array(0..<(gridSize*gridSize))
        sequence = []
        
        for _ in 0..<sequenceLength {
            let randomIndex = Int.random(in: 0..<availableIndices.count)
            sequence.append(availableIndices.remove(at: randomIndex))
        }
        
        userSequence = []
        gameState = .instruction
        print("🎯 New sequence generated: \(sequence)")
    }
    
    private func showSequence() {
        var delay: Double = 0
        for (index, tile) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                showingTiles = true
                currentTileIndex = tile
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingTiles = false
                    
                    if index == sequence.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            gameState = .input
                        }
                    }
                }
            }
            delay += 1.0
        }
    }
    
    private func handleTileTap(_ index: Int) {
        userSequence.append(index)
        print("🔥 User tapped: \(index), sequence so far: \(userSequence)")
        print("🎯 Expected sequence: \(sequence)")
        
        // Проверяем правильность текущего нажатия
        if userSequence.count <= sequence.count && 
           userSequence[userSequence.count - 1] == sequence[userSequence.count - 1] {
            // Правильное нажатие
            if userSequence.count == sequence.count {
                // Последовательность завершена правильно
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameState = .result
                }
            }
        } else {
            // Неправильное нажатие - сразу показываем результат
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameState = .result
            }
        }
    }
}
