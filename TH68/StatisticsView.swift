//
//  StatisticsView.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var gameData: GameData
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkGraphite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Overall Progress
                        VStack(spacing: 15) {
                            Text("Overall Progress")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                                .onAppear {
                                    print("📊 StatisticsView - gameData scores: \(gameData.scores)")
                                    print("📊 StatisticsView - gameData rewards: \(gameData.rewards)")
                                    print("📊 StatisticsView - overall average: \(gameData.overallAverageScore())")
                                }
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(gameData.overallAverageScore() / 100))
                                    .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                Text(String(format: "%.0f", gameData.overallAverageScore()))
                                    .font(.title.weight(.bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Game Statistics
                        VStack(spacing: 20) {
                            Text("Game Performance")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            
                            ForEach(GameType.allCases, id: \.self) { game in
                                GameStatRow(game: game, average: gameData.averageScore(for: game))
                            }
                        }
                        
                        // Rewards Gallery
                        VStack(spacing: 20) {
                            Text("Rewards Gallery")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                                ForEach(RewardType.allCases, id: \.self) { reward in
                                    RewardCard(reward: reward, isEarned: gameData.rewards.contains(reward))
                                }
                            }
                        }
                        
                        // Reset Button
                        Button("Reset Progress") {
                            showingResetAlert = true
                        }
                        .buttonStyle(DestructiveButtonStyle())
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameData.resetProgress()
            }
        } message: {
            Text("This will clear all statistics and rewards. This action cannot be undone.")
        }
    }
}

// MARK: - Game Stat Row
struct GameStatRow: View {
    let game: GameType
    let average: Double
    
    var body: some View {
        HStack {
            Image(systemName: game.icon)
                .font(.title2)
                .foregroundColor(.neonGreen)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(game.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Average: \(String(format: "%.0f", average))")
                    .font(.caption)
                    .foregroundColor(.lightGray)
            }
            
            Spacer()
            
            // Progress bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.neonGreen)
                    .frame(width: CGFloat(min(average / 100, 1.0)) * 100, height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Reward Card
struct RewardCard: View {
    let reward: RewardType
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: reward.icon)
                .font(.system(size: 40))
                .foregroundColor(isEarned ? reward.color : Color.gray)
            
            Text(reward.rawValue)
                .font(.caption.weight(.medium))
                .foregroundColor(isEarned ? .white : .gray)
                .multilineTextAlignment(.center)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isEarned ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEarned ? reward.color.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isEarned ? 1.0 : 0.9)
        .opacity(isEarned ? 1.0 : 0.5)
    }
}
