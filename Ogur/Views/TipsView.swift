import SwiftUI

struct PlantTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let category: TipCategory
    
    enum TipCategory: String, CaseIterable {
        case watering = "Watering"
        case feeding = "Feeding"
        case general = "General"
        case tomatoes = "Tomatoes"
        case cucumbers = "Cucumbers"
    }
    
    static let tips: [PlantTip] = [
        PlantTip(title: "Morning Watering", description: "Water your plants in the morning to reduce evaporation and give them time to dry before evening.", icon: "sunrise.fill", category: .watering),
        PlantTip(title: "Check Soil Moisture", description: "Insert your finger 2 inches into the soil. If it's dry, it's time to water.", icon: "hand.point.down.fill", category: .watering),
        PlantTip(title: "Deep Watering", description: "Water deeply but less frequently to encourage deep root growth.", icon: "drop.fill", category: .watering),
        PlantTip(title: "Avoid Leaf Watering", description: "Water the soil, not the leaves, to prevent fungal diseases.", icon: "leaf.fill", category: .watering),
        PlantTip(title: "Balanced Fertilizer", description: "Use a balanced fertilizer (10-10-10) for general plant health.", icon: "leaf.circle.fill", category: .feeding),
        PlantTip(title: "Don't Over-Fertilize", description: "Too much fertilizer can burn roots. Less is often more.", icon: "exclamationmark.triangle.fill", category: .feeding),
        PlantTip(title: "Organic Options", description: "Compost and worm castings are excellent organic fertilizer alternatives.", icon: "leaf.arrow.circlepath", category: .feeding),
        PlantTip(title: "Sunlight Needs", description: "Most vegetables need 6-8 hours of direct sunlight daily.", icon: "sun.max.fill", category: .general),
        PlantTip(title: "Air Circulation", description: "Good air circulation helps prevent disease. Don't overcrowd plants.", icon: "wind", category: .general),
        PlantTip(title: "Regular Inspection", description: "Check plants regularly for pests and diseases. Early detection is key.", icon: "magnifyingglass", category: .general),
        PlantTip(title: "Tomato Pruning", description: "Remove suckers (side shoots) to direct energy to fruit production.", icon: "scissors", category: .tomatoes),
        PlantTip(title: "Tomato Support", description: "Use stakes or cages to support tomato plants as they grow.", icon: "arrow.up.circle.fill", category: .tomatoes),
        PlantTip(title: "Consistent Watering", description: "Inconsistent watering causes blossom end rot in tomatoes.", icon: "drop.triangle.fill", category: .tomatoes),
        PlantTip(title: "Cucumber Trellising", description: "Train cucumbers to grow vertically for better air circulation and easier harvesting.", icon: "arrow.up.right", category: .cucumbers),
        PlantTip(title: "Frequent Harvesting", description: "Harvest cucumbers often to encourage more fruit production.", icon: "hand.raised.fill", category: .cucumbers),
        PlantTip(title: "Consistent Moisture", description: "Cucumbers need consistent moisture - don't let them dry out.", icon: "humidity.fill", category: .cucumbers),
    ]
}

struct TipsView: View {
    @State private var selectedCategory: PlantTip.TipCategory?
    
    var filteredTips: [PlantTip] {
        if let category = selectedCategory {
            return PlantTip.tips.filter { $0.category == category }
        }
        return PlantTip.tips
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    categoryPicker
                    ForEach(filteredTips) { tip in TipCard(tip: tip) }
                }.padding()
            }
        }
        .navigationTitle("Plant Tips 💡")
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", icon: "leaf.fill", isSelected: selectedCategory == nil) { withAnimation { selectedCategory = nil } }
                ForEach(PlantTip.TipCategory.allCases, id: \.self) { category in
                    CategoryChip(title: category.rawValue, icon: iconFor(category), isSelected: selectedCategory == category) { withAnimation { selectedCategory = category } }
                }
            }
        }
    }
    
    private func iconFor(_ category: PlantTip.TipCategory) -> String {
        switch category {
        case .watering: return "drop.fill"
        case .feeding: return "leaf.circle.fill"
        case .general: return "info.circle.fill"
        case .tomatoes: return "circle.fill"
        case .cucumbers: return "oval.fill"
        }
    }
}

struct CategoryChip: View {
    let title: String, icon: String, isSelected: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) { Image(systemName: icon).font(.caption); Text(title).font(.subheadline.weight(.medium)) }
                .foregroundColor(isSelected ? .white : .primary).padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected ? Color.leafGreen : Color(.systemBackground)).clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

struct TipCard: View {
    let tip: PlantTip
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tip.icon).font(.title2).foregroundColor(.leafGreen).frame(width: 40, height: 40).background(Color.leafGreen.opacity(0.15)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(tip.title).font(.headline).foregroundColor(.primary)
                    Spacer()
                    Text(tip.category.rawValue).font(.caption2).foregroundColor(.secondary).padding(.horizontal, 8).padding(.vertical, 2).background(Color(.systemBackground)).clipShape(Capsule())
                }
                Text(tip.description).font(.subheadline).foregroundColor(.secondary)
            }
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

#Preview { NavigationStack { TipsView() } }
