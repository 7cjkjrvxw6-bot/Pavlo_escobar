import SwiftUI

struct GardenView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView { VStack(spacing: 20) { gardenStatsCard; quickActions; dailyTipCard; achievementsPreview }.padding() }
            }
            .navigationTitle("Garden Hub 🏡")
        }
    }
    
    private var gardenStatsCard: some View {
        VStack(spacing: 16) {
            HStack { Text("Your Garden").font(.headline).foregroundColor(.primary); Spacer(); Text(gardenLevel).font(.caption.weight(.medium)).foregroundColor(.white).padding(.horizontal, 10).padding(.vertical, 4).background(Color.leafGreen).clipShape(Capsule()) }
            HStack(spacing: 20) {
                GardenStatBubble(value: "\(dataManager.totalPlants)", label: "Plants", icon: "leaf.fill", color: .leafGreen)
                GardenStatBubble(value: "\(dataManager.totalWaterings)", label: "Waterings", icon: "drop.fill", color: .waterColor)
                GardenStatBubble(value: "\(dataManager.totalPhotos)", label: "Photos", icon: "camera.fill", color: .photoColor)
                GardenStatBubble(value: "\(unlockedAchievements)", label: "Badges", icon: "star.fill", color: .sunYellow)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack { Text("Garden XP").font(.caption).foregroundColor(.secondary); Spacer(); Text("\(currentXP) / \(nextLevelXP)").font(.caption.weight(.medium)).foregroundColor(.primary) }
                GeometryReader { geo in ZStack(alignment: .leading) { RoundedRectangle(cornerRadius: 4).fill(Color.leafGreen.opacity(0.2)); RoundedRectangle(cornerRadius: 4).fill(Color.leafGreen).frame(width: geo.size.width * xpProgress) } }.frame(height: 8)
            }
        }.padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: AchievementsView(dataManager: dataManager)) { QuickActionCard(title: "Achievements", icon: "trophy.fill", color: .sunYellow, badge: unlockedAchievements > 0 ? "\(unlockedAchievements)" : nil) }
            NavigationLink(destination: TipsView()) { QuickActionCard(title: "Plant Tips", icon: "lightbulb.fill", color: .orange, badge: nil) }
            NavigationLink(destination: WaterDropGameView()) { QuickActionCard(title: "Mini Game", icon: "gamecontroller.fill", color: .purple, badge: "Play") }
        }
    }
    
    private var dailyTipCard: some View {
        let tip = PlantTip.tips.randomElement()!
        return VStack(alignment: .leading, spacing: 12) {
            HStack { Image(systemName: "lightbulb.fill").foregroundColor(.orange); Text("Tip of the Day").font(.headline).foregroundColor(.primary) }
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: tip.icon).font(.title2).foregroundColor(.leafGreen).frame(width: 40, height: 40).background(Color.leafGreen.opacity(0.15)).clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) { Text(tip.title).font(.subheadline.weight(.semibold)).foregroundColor(.primary); Text(tip.description).font(.caption).foregroundColor(.secondary) }
            }
        }.padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Recent Achievements").font(.headline).foregroundColor(.primary); Spacer(); NavigationLink(destination: AchievementsView(dataManager: dataManager)) { Text("See All").font(.subheadline).foregroundColor(.leafGreen) } }
            let recentAchievements = getUnlockedAchievements().prefix(3)
            if recentAchievements.isEmpty {
                HStack { Image(systemName: "trophy").font(.largeTitle).foregroundColor(.secondary); VStack(alignment: .leading) { Text("No achievements yet").font(.subheadline.weight(.medium)).foregroundColor(.primary); Text("Start gardening to unlock badges!").font(.caption).foregroundColor(.secondary) } }
                    .frame(maxWidth: .infinity, alignment: .leading).padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack(spacing: 16) { ForEach(Array(recentAchievements), id: \.id) { achievement in VStack(spacing: 8) { Text(achievement.icon).font(.system(size: 36)); Text(achievement.title).font(.caption2).foregroundColor(.primary).multilineTextAlignment(.center) }.frame(maxWidth: .infinity) } }
                    .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var gardenLevel: String { let xp = currentXP; if xp < 50 { return "🌱 Beginner" }; if xp < 150 { return "🌿 Gardener" }; if xp < 300 { return "🌳 Expert" }; return "🏆 Master" }
    private var currentXP: Int { dataManager.totalPlants * 10 + dataManager.totalWaterings * 2 + dataManager.totalFeedings * 3 + dataManager.totalPhotos * 5 }
    private var nextLevelXP: Int { let xp = currentXP; if xp < 50 { return 50 }; if xp < 150 { return 150 }; if xp < 300 { return 300 }; return 500 }
    private var xpProgress: CGFloat { CGFloat(currentXP) / CGFloat(nextLevelXP) }
    private var unlockedAchievements: Int { getUnlockedAchievements().count }
    
    private func getUnlockedAchievements() -> [Achievement] {
        var unlocked: [Achievement] = []
        if dataManager.totalPlants >= 1 { unlocked.append(Achievement.allAchievements[0]) }
        if dataManager.totalPlants >= 5 { unlocked.append(Achievement.allAchievements[1]) }
        if dataManager.totalWaterings >= 1 { unlocked.append(Achievement.allAchievements[3]) }
        if dataManager.totalPhotos >= 1 { unlocked.append(Achievement.allAchievements[5]) }
        if dataManager.totalPhotos >= 25 { unlocked.append(Achievement.allAchievements[6]) }
        if dataManager.plants.contains(where: { $0.currentPhase == .fruiting }) { unlocked.append(Achievement.allAchievements[7]) }
        return unlocked
    }
}

struct GardenStatBubble: View {
    let value: String, label: String, icon: String, color: Color
    var body: some View {
        VStack(spacing: 6) {
            ZStack { Circle().fill(color.opacity(0.15)).frame(width: 50, height: 50); Image(systemName: icon).font(.title3).foregroundColor(color) }
            Text(value).font(.headline).foregroundColor(.primary); Text(label).font(.caption2).foregroundColor(.secondary)
        }.frame(maxWidth: .infinity)
    }
}

struct QuickActionCard: View {
    let title: String, icon: String, color: Color, badge: String?
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon).font(.title2).foregroundColor(color).frame(width: 50, height: 50).background(color.opacity(0.15)).clipShape(Circle())
                if let badge = badge { Text(badge).font(.caption2.weight(.bold)).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 2).background(color).clipShape(Capsule()).offset(x: 8, y: -4) }
            }
            Text(title).font(.caption.weight(.medium)).foregroundColor(.primary)
        }.frame(maxWidth: .infinity).padding(.vertical, 16).background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

#Preview { GardenView(dataManager: DataManager.shared) }
