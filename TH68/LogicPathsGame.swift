//
//  LogicPathsGame.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct LogicPathsGame: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameData: GameData
    @State private var gameState: LogicGameState = .instruction
    @State private var currentPuzzle: LogicPuzzle?
    @State private var selectedPath: [Int] = []
    @State private var score = 0
    @State private var level = 1
    @State private var isCorrect = false
    
    private let maxLevel = 12
    
    enum LogicGameState {
        case instruction, playing, result, complete
    }
    
    struct LogicPuzzle {
        let nodes: [LogicNode]
        let correctPath: [Int]
        let rule: String
    }
    
    struct LogicNode {
        let id: Int
        let value: Int
        let connections: [Int]
        let position: CGPoint
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Logic Paths")
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
    }
    
    private var instructionView: some View {
        VStack(spacing: 20) {
            Text("Choose the correct sequence to reach the goal")
                .font(.title2)
                .foregroundColor(.lightGray)
                .multilineTextAlignment(.center)
            
            Text("Level \(level)")
                .font(.title.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            if let puzzle = currentPuzzle {
                Text("Rule: \(puzzle.rule)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.goldenOrange)
                    .multilineTextAlignment(.center)
            }
            
            Button("Start") {
                gameState = .playing
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 20) {
            if let puzzle = currentPuzzle {
                Text("Rule: \(puzzle.rule)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.goldenOrange)
                    .multilineTextAlignment(.center)
                
                // Path visualization
                ZStack {
                    // Draw connections
                    ForEach(puzzle.nodes, id: \.id) { node in
                        ForEach(node.connections, id: \.self) { connectionId in
                            if let connectedNode = puzzle.nodes.first(where: { $0.id == connectionId }) {
                                Path { path in
                                    path.move(to: node.position)
                                    path.addLine(to: connectedNode.position)
                                }
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            }
                        }
                    }
                    
                    // Draw nodes
                    ForEach(puzzle.nodes, id: \.id) { node in
                        Circle()
                            .fill(nodeColor(for: node))
                            .frame(width: 50, height: 50)
                            .position(node.position)
                            .overlay(
                                Text("\(node.value)")
                                    .font(.headline.weight(.bold))
                                    
                                    .foregroundColor(.white)
                                    .position(node.position)
                            )
                            .onTapGesture {
                                handleNodeTap(node.id)
                            }
                    }
                }
                .frame(height: 300)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Selected path
                if !selectedPath.isEmpty {
                    Text("Path: \(selectedPath.map { nodeId in puzzle.nodes.first(where: { $0.id == nodeId })?.value ?? 0 }.map(String.init).joined(separator: " → "))")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.neonGreen)
                }
                
                HStack(spacing: 20) {
                    Button("Reset") {
                        selectedPath = []
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Submit") {
                        checkAnswer()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedPath.isEmpty)
                }
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Text(isCorrect ? "Perfect Logic!" : "Try Again")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(isCorrect ? .neonGreen : .crimsonPink)
            
            if isCorrect {
                Text("Level \(level) Complete!")
                    .font(.title2)
                    .foregroundColor(.white)
            } else if let puzzle = currentPuzzle {
                Text("Correct path: \(puzzle.correctPath.map { nodeId in puzzle.nodes.first(where: { $0.id == nodeId })?.value ?? 0 }.map(String.init).joined(separator: " → "))")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.goldenOrange)
            }
            
            Button("Continue") {
                if isCorrect {
                    // Сохраняем статистику после каждого успешного уровня
                    let levelScore = level * 20
                    score += levelScore
                    gameData.addScore(levelScore, for: .logicPaths)
                    gameData.addReward(.badgeOfLogic)
                    
                    if level < maxLevel {
                        level += 1
                        startNewLevel()
                    } else {
                        gameState = .complete
                    }
                } else if !isCorrect {
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
            Text("Logic Master!")
                .font(.largeTitle.weight(.bold))
                
                .foregroundColor(.neonGreen)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white)
            
            Image(systemName: RewardType.badgeOfLogic.icon)
                .font(.system(size: 60))
                .foregroundColor(RewardType.badgeOfLogic.color)
            
            Text("You earned: \(RewardType.badgeOfLogic.rawValue)")
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
    
    private func nodeColor(for node: LogicNode) -> Color {
        if selectedPath.contains(node.id) {
            return .neonGreen
        } else if selectedPath.isEmpty && node.id == 0 {
            return .crimsonPink // Start node
        } else {
            return Color.gray.opacity(0.6)
        }
    }
    
    private func startNewLevel() {
        gameState = .instruction
        selectedPath = []
        generatePuzzle()
    }
    
    private func generatePuzzle() {
        let nodeCount = min(6, 3 + level / 2)
        var nodes: [LogicNode] = []
        
        // Create nodes in a grid-like pattern
        let cols = 3
        let rows = (nodeCount + cols - 1) / cols
        
        for i in 0..<nodeCount {
            let row = i / cols
            let col = i % cols
            let x = 50 + CGFloat(col) * 100
            let y = 50 + CGFloat(row) * 80
            
            let value = Int.random(in: 1...9)
            var connections: [Int] = []
            
            // Add some connections
            if i < nodeCount - 1 {
                connections.append(i + 1)
            }
            if col < cols - 1 && i + 1 < nodeCount {
                connections.append(i + 1)
            }
            if row < rows - 1 && i + cols < nodeCount {
                connections.append(i + cols)
            }
            
            nodes.append(LogicNode(id: i, value: value, connections: connections, position: CGPoint(x: x, y: y)))
        }
        
        // Generate rule and correct path
        let rules = [
            "Follow ascending numbers",
            "Choose even numbers only",
            "Pick the largest available",
            "Follow multiples of 3"
        ]
        
        let rule = rules.randomElement()!
        let correctPath = generateCorrectPath(for: nodes, rule: rule)
        
        currentPuzzle = LogicPuzzle(nodes: nodes, correctPath: correctPath, rule: rule)
    }
    
    private func generateCorrectPath(for nodes: [LogicNode], rule: String) -> [Int] {
        // Simple path generation based on rule
        var path: [Int] = [0] // Start at first node
        var current = 0
        
        while path.count < min(4, nodes.count) && current < nodes.count - 1 {
            let currentNode = nodes[current]
            let availableNext = currentNode.connections.filter { !path.contains($0) }
            
            if let next = availableNext.randomElement() {
                path.append(next)
                current = next
            } else {
                break
            }
        }
        
        return path
    }
    
    private func handleNodeTap(_ nodeId: Int) {
        if selectedPath.isEmpty {
            // Must start with node 0
            if nodeId == 0 {
                selectedPath.append(nodeId)
            }
        } else {
            let lastNode = selectedPath.last!
            if let node = currentPuzzle?.nodes.first(where: { $0.id == lastNode }),
               node.connections.contains(nodeId) && !selectedPath.contains(nodeId) {
                selectedPath.append(nodeId)
            }
        }
    }
    
    private func checkAnswer() {
        isCorrect = selectedPath == currentPuzzle?.correctPath
        gameState = .result
    }
}
