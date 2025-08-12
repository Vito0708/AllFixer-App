//
//  ToolBackgroundView.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 18/03/2025.
//

import SwiftUI

struct ToolBackgroundView: View {
    @State private var animate = false

    let toolIcons = ["wrench.fill", "hammer.fill", "screwdriver.fill", "paintbrush.fill", "briefcase.fill"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<30, id: \.self) { index in
                    let randomX = CGFloat.random(in: 0...geometry.size.width)
                    let randomY = CGFloat.random(in: 0...geometry.size.height)
                    let randomSize = CGFloat.random(in: 20...50)

                    Image(systemName: toolIcons.randomElement() ?? "wrench.fill")
                        .resizable()
                        .frame(width: randomSize, height: randomSize)
                        .foregroundColor(Color.blue.opacity(0.3)) 
                        .position(x: animate ? randomX : randomX + 5, y: randomY)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                        )
                }
            }
            .onAppear {
                animate.toggle()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


