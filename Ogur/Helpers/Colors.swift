import SwiftUI

extension Color {
    static let leafGreen = Color(red: 0.13, green: 0.55, blue: 0.13)
    static let softBeige = Color(red: 0.96, green: 0.96, blue: 0.94)
    static let warmBrown = Color(red: 0.55, green: 0.35, blue: 0.2)
    static let skyBlue = Color(red: 0.25, green: 0.6, blue: 0.9)
    static let sunYellow = Color(red: 0.95, green: 0.75, blue: 0.1)
    
    static let seedColor = Color(red: 0.5, green: 0.4, blue: 0.3)
    static let sproutColor = Color(red: 0.3, green: 0.7, blue: 0.3)
    static let growingColor = Color(red: 0.1, green: 0.6, blue: 0.3)
    static let bloomingColor = Color(red: 0.85, green: 0.35, blue: 0.5)
    static let fruitingColor = Color(red: 0.9, green: 0.3, blue: 0.2)
    static let restingColor = Color(red: 0.45, green: 0.45, blue: 0.55)
    
    static let waterColor = Color(red: 0.2, green: 0.5, blue: 0.85)
    static let feedingColor = Color(red: 0.85, green: 0.6, blue: 0.1)
    static let photoColor = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let phaseColor = Color(red: 0.55, green: 0.35, blue: 0.75)
    
    static let cardBackground = Color(.systemBackground)
    static let mainBackground = Color(.systemGroupedBackground)
    
    static func phaseColor(for phase: PlantPhase) -> Color {
        switch phase {
        case .seed: return .seedColor
        case .sprout: return .sproutColor
        case .growing: return .growingColor
        case .blooming: return .bloomingColor
        case .fruiting: return .fruitingColor
        case .resting: return .restingColor
        }
    }
    
    static func careColor(for type: CareType) -> Color {
        switch type {
        case .watering: return .waterColor
        case .feeding: return .feedingColor
        }
    }
}

extension LinearGradient {
    static let mainGradient = LinearGradient(
        colors: [Color.mainBackground, Color.softBeige],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.cardBackground, Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let headerGradient = LinearGradient(
        colors: [Color.leafGreen, Color.leafGreen.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
