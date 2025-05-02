//
//  SplashView.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//
import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Background adapts to system theme
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                

                        Image("bandlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 0.8)) {
                                    logoScale = 1.0
                                    logoOpacity = 1.0
                                }
                            }
                    

                    Text("BandSync")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .onAppear {
                    // Delay before switching to ContentView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}


