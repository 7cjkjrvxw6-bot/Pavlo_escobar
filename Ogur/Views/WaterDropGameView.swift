import SwiftUI
import Combine

struct WaterDropGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.6, green: 0.85, blue: 1), Color(red: 0.3, green: 0.6, blue: 0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Clouds decoration
                CloudsView()
                
                if !gameState.isPlaying && !gameState.isGameOver {
                    startScreen
                } else if gameState.isGameOver {
                    gameOverScreen
                } else {
                    gameScreen(geometry: geometry)
                }
            }
            .onAppear {
                gameState.screenSize = geometry.size
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            gameState.stopGame()
        }
    }
    
    private var startScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated drop
            Text("💧")
                .font(.system(size: 100))
                .shadow(color: .blue.opacity(0.5), radius: 20)
            
            Text("Water Drop")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
            
            Text("Catch the drops to water your plants!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(spacing: 4) {
                Text("🏆 Best Score")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(gameState.highScore)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                gameState.startGame()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .font(.title3.weight(.semibold))
                .foregroundColor(.blue)
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
            
            Text("Drag left/right to move bucket")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
        .padding()
    }
    
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if gameState.score > gameState.previousHighScore {
                Text("🎉")
                    .font(.system(size: 80))
                Text("New High Score!")
                    .font(.title.weight(.bold))
                    .foregroundColor(.yellow)
            } else {
                Text("😢")
                    .font(.system(size: 80))
                Text("Game Over")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(gameState.score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if gameState.score > gameState.previousHighScore {
                Text("Previous best: \(gameState.previousHighScore)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 16) {
                Button {
                    gameState.startGame()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Again")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.white)
                    .clipShape(Capsule())
                }
                
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Exit")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.3))
                    .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func gameScreen(geometry: GeometryProxy) -> some View {
        let bucketY = geometry.size.height - 100
        
        return ZStack {
            // HUD
            VStack {
                HStack {
                    // Lives
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < gameState.lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                    .padding(8)
                    .background(.white.opacity(0.3))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Score
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameState.score)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.3))
                    .clipShape(Capsule())
                }
                .padding()
                
                Spacer()
            }
            
            // Drops
            ForEach(gameState.drops) { drop in
                Text("💧")
                    .font(.system(size: 40))
                    .position(x: drop.x, y: drop.y)
            }
            
            // Bucket - using emoji for reliability
            Text("🪣")
                .font(.system(size: 70))
                .position(x: gameState.bucketX, y: bucketY)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newX = value.location.x
                    gameState.bucketX = max(50, min(geometry.size.width - 50, newX))
                }
        )
        .onAppear {
            gameState.bucketX = geometry.size.width / 2
            gameState.screenSize = geometry.size
            gameState.catchY = bucketY
        }
    }
}

struct CloudsView: View {
    var body: some View {
        VStack {
            HStack {
                Cloud()
                    .offset(x: -30, y: 50)
                Spacer()
                Cloud()
                    .offset(x: 20, y: 30)
            }
            Spacer()
        }
        .opacity(0.6)
    }
}

struct Cloud: View {
    var body: some View {
        HStack(spacing: -20) {
            Circle().frame(width: 40, height: 40)
            Circle().frame(width: 60, height: 60)
            Circle().frame(width: 40, height: 40)
        }
        .foregroundColor(.white)
    }
}

@MainActor
class GameState: ObservableObject {
    @Published var drops: [WaterDrop] = []
    @Published var score = 0
    @Published var lives = 3
    @Published var isPlaying = false
    @Published var isGameOver = false
    @Published var bucketX: CGFloat = 200
    @Published var highScore = UserDefaults.standard.integer(forKey: "waterDropHighScore")
    
    var previousHighScore = 0
    var screenSize: CGSize = .zero
    var catchY: CGFloat = 0
    
    private var displayLink: CADisplayLink?
    private var lastDropTime: CFTimeInterval = 0
    private var dropInterval: CFTimeInterval = 1.0
    
    let bucketWidth: CGFloat = 80
    let bucketHeight: CGFloat = 70
    
    func startGame() {
        score = 0
        lives = 3
        drops = []
        isGameOver = false
        isPlaying = true
        previousHighScore = highScore
        lastDropTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopGame() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func gameLoop() {
        guard isPlaying, !isGameOver else {
            stopGame()
            return
        }
        
        let currentTime = CACurrentMediaTime()
        
        // Spawn new drops
        if currentTime - lastDropTime >= dropInterval {
            spawnDrop()
            lastDropTime = currentTime
            // Speed up over time
            dropInterval = max(0.4, dropInterval - 0.01)
        }
        
        // Update drops
        updateDrops()
    }
    
    private func spawnDrop() {
        let padding: CGFloat = 50
        let x = CGFloat.random(in: padding...(screenSize.width - padding))
        let drop = WaterDrop(x: x, y: -30, speed: CGFloat.random(in: 4...7))
        drops.append(drop)
    }
    
    private func updateDrops() {
        for i in drops.indices.reversed() {
            drops[i].y += drops[i].speed
            
            // Check catch - use the catchY from the view
            let dx = abs(drops[i].x - bucketX)
            let dy = abs(drops[i].y - catchY)
            
            if dx < bucketWidth / 2 && dy < bucketHeight / 2 {
                // Caught!
                score += 1
                drops.remove(at: i)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else if drops[i].y > screenSize.height + 30 {
                // Missed
                lives -= 1
                drops.remove(at: i)
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                
                if lives <= 0 {
                    endGame()
                }
            }
        }
    }
    
    private func endGame() {
        isPlaying = false
        isGameOver = true
        stopGame()
        dropInterval = 1.0
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "waterDropHighScore")
        }
    }
}

struct WaterDrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
}

#Preview {
    WaterDropGameView()
}
