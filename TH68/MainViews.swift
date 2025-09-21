//
//  MainViews.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

// MARK: - Main Navigation View
struct MainNavigationView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainScreenView()
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Games")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
                .tag(1)
        }
        .accentColor(.neonGreen)
    }
}

// MARK: - Main Screen View
struct MainScreenView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkGraphite.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(GameType.allCases, id: \.self) { game in
                            GameCardWithSheet(game: game)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Challenges")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Game Card with Built-in Sheet
struct GameCardWithSheet: View {
    let game: GameType
    @State private var showingGame = false
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        GameCardView(game: game) {
            showingGame = true
        }
        .sheet(isPresented: $showingGame) {
            GameSheetView(game: game, isPresented: $showingGame)
                .environmentObject(gameData)
        }
    }
}

// MARK: - Game Sheet View
struct GameSheetView: View {
    let game: GameType
    @Binding var isPresented: Bool
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkGraphite.ignoresSafeArea()
                
                // Настоящие игровые экраны
                switch game {
                case .memoryMatrix:
                    MemoryMatrixGame(isPresented: $isPresented)
                        .environmentObject(gameData)
                case .focusFlash:
                    FocusFlashGame(isPresented: $isPresented)
                        .environmentObject(gameData)
                case .quickMath:
                    QuickMathGame(isPresented: $isPresented)
                        .environmentObject(gameData)
                case .logicPaths:
                    LogicPathsGame(isPresented: $isPresented)
                        .environmentObject(gameData)
                }
            }
            .navigationTitle(game.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.crimsonPink)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let game: GameType
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: game.icon)
                    .font(.title2)
                    .foregroundColor(.neonGreen)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(game.rawValue)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                
                Text(game.description)
                    .font(.caption)
                    .foregroundColor(.lightGray)
                    .lineLimit(3)
            }
            
            Button("Play") {
                action()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }
    }
}


