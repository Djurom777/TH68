//
//  OnboardingView.swift
//  MindCascade
//
//  Created by IGOR on 19/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var gameData: GameData
    @State private var currentSlide = 0
    @State private var showContent = false
    
    private let slides = [
        "Test your thinking speed",
        "Play engaging logic mini-games",
        "Track your progress and earn unique rewards"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Slide content
            VStack(spacing: 30) {
                if currentSlide < slides.count {
                    slideContent(for: currentSlide)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .animation(.easeOut(duration: 0.6), value: showContent)
                }
            }
            
            Spacer()
            
            // Navigation
            HStack(spacing: 20) {
                if currentSlide < slides.count - 1 {
                    Button("Next") {
                        nextSlide()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button("Start") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            gameData.hasCompletedOnboarding = true
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            showSlideContent()
        }
    }
    
    @ViewBuilder
    private func slideContent(for slide: Int) -> some View {
        switch slide {
        case 0:
            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 80))
                    .foregroundColor(.neonGreen)
                Text(slides[slide])
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        case 1:
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    ForEach(["grid", "eye", "function", "arrow.triangle.branch"], id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundColor(.crimsonPink)
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(.spring().delay(Double(["grid", "eye", "function", "arrow.triangle.branch"].firstIndex(of: icon) ?? 0) * 0.1), value: showContent)
                    }
                }
                Text(slides[slide])
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        case 2:
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 120)
                    .overlay(
                        VStack {
                            HStack {
                                Image(systemName: "diamond")
                                    .foregroundColor(.blue)
                                Image(systemName: "flame")
                                    .foregroundColor(.crimsonPink)
                            }
                            .font(.title2)
                            HStack {
                                Image(systemName: "shield")
                                    .foregroundColor(.goldenOrange)
                                Image(systemName: "star")
                                    .foregroundColor(.neonGreen)
                            }
                            .font(.title2)
                        }
                    )
                    .offset(x: showContent ? 0 : 100)
                    .animation(.easeOut(duration: 0.8), value: showContent)
                
                Text(slides[slide])
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        default:
            EmptyView()
        }
    }
    
    private func nextSlide() {
        showContent = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentSlide += 1
            showSlideContent()
        }
    }
    
    private func showSlideContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showContent = true
        }
    }
}
