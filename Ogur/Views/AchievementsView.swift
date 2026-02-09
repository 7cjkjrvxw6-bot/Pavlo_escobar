import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: String
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_plant", title: "First Seed", description: "Add your first plant", icon: "🌱", requirement: "1 plant"),
        Achievement(id: "five_plants", title: "Growing Garden", description: "Have 5 plants", icon: "🌿", requirement: "5 plants"),
        Achievement(id: "ten_plants", title: "Plant Master", description: "Have 10 plants", icon: "🌳", requirement: "10 plants"),
        Achievement(id: "first_water", title: "First Drop", description: "Water a plant", icon: "💧", requirement: "1 watering"),
        Achievement(id: "hundred_waters", title: "Rain Maker", description: "Water 100 times", icon: "🌧", requirement: "100 waterings"),
        Achievement(id: "first_photo", title: "Photographer", description: "Take a photo", icon: "📸", requirement: "1 photo"),
        Achievement(id: "photo_album", title: "Photo Album", description: "Take 25 photos", icon: "📷", requirement: "25 photos"),
        Achievement(id: "first_harvest", title: "First Harvest", description: "Plant reaches fruiting stage", icon: "🍅", requirement: "1 fruiting plant"),
        Achievement(id: "green_thumb", title: "Green Thumb", description: "Earn 100 XP", icon: "🌻", requirement: "100 XP"),
        Achievement(id: "expert", title: "Expert Gardener", description: "Earn 300 XP", icon: "🏆", requirement: "300 XP"),
    ]
}

struct AchievementsView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Achievement.allAchievements) { achievement in
                        AchievementCard(achievement: achievement, isUnlocked: isUnlocked(achievement))
                    }
                }.padding()
            }
        }
        .navigationTitle("Achievements 🏆")
    }
    
    private func isUnlocked(_ achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_plant": return dataManager.totalPlants >= 1
        case "five_plants": return dataManager.totalPlants >= 5
        case "ten_plants": return dataManager.totalPlants >= 10
        case "first_water": return dataManager.totalWaterings >= 1
        case "hundred_waters": return dataManager.totalWaterings >= 100
        case "first_photo": return dataManager.totalPhotos >= 1
        case "photo_album": return dataManager.totalPhotos >= 25
        case "first_harvest": return dataManager.plants.contains { $0.currentPhase == .fruiting }
        case "green_thumb": return currentXP >= 100
        case "expert": return currentXP >= 300
        default: return false
        }
    }
    
    private var currentXP: Int {
        dataManager.totalPlants * 10 + dataManager.totalWaterings * 2 + dataManager.totalFeedings * 3 + dataManager.totalPhotos * 5
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(isUnlocked ? Color.sunYellow.opacity(0.2) : Color.gray.opacity(0.1)).frame(width: 60, height: 60)
                Text(achievement.icon).font(.system(size: 30)).opacity(isUnlocked ? 1 : 0.3).grayscale(isUnlocked ? 0 : 1)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title).font(.headline).foregroundColor(isUnlocked ? .primary : .secondary)
                    if isUnlocked { Image(systemName: "checkmark.seal.fill").foregroundColor(.leafGreen) }
                }
                Text(achievement.description).font(.subheadline).foregroundColor(.secondary)
                Text(achievement.requirement).font(.caption).foregroundColor(isUnlocked ? .leafGreen : .secondary)
            }
            Spacer()
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1).opacity(isUnlocked ? 1 : 0.7)
    }
}

#Preview { NavigationStack { AchievementsView(dataManager: DataManager.shared) } }
