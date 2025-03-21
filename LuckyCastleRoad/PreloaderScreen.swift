//
//  PreloaderView.swift
//  LuckyCastleRoad
//
//  Created by alex on 3/21/25.
//

import SwiftUI


struct LoadingScreen: View {
    var progress: Double
    @State private var rotationAngle: Double = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 20) {
                    
                    
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                    
                    
                    
                    
                    Spacer()
                    
                    
                    VStack {
                        Spacer()
                        HStack {
                            Image(.chicccc)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.6)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                
                ZStack {
                    // Вращающийся круговой загрузчик
                    Circle()
                        .trim(from: 0.0, to: 0.7) // Длина дуги (70% круга)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: Double(rotationAngle)))
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                        .onAppear {
                            rotationAngle = 360
                        }
                    
              
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
            }
            .frame(width: geometry.size.width)
            .background(
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    LoadingScreen(progress: 0.75)
}
