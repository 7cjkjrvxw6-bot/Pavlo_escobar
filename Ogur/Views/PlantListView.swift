import SwiftUI

struct PlantListView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showAddPlant = false
    @State private var searchText = ""
    @State private var selectedFilter: PlantType? = nil
    
    var filteredPlants: [Plant] {
        var result = dataManager.plants
        if let filter = selectedFilter { result = result.filter { $0.type == filter } }
        if !searchText.isEmpty { result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.displayType.localizedCaseInsensitiveContains(searchText) } }
        return result.sorted { $0.plantedDate > $1.plantedDate }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                if dataManager.plants.isEmpty { emptyState } else { plantsList }
            }
            .navigationTitle("My Plants 🌱")
            .searchable(text: $searchText, prompt: "Search plants")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddPlant = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.leafGreen)
                    }
                }
            }
            .sheet(isPresented: $showAddPlant) { AddPlantView(dataManager: dataManager) }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.leafGreen.opacity(0.15)).frame(width: 160, height: 160)
                Text("🌱").font(.system(size: 80))
            }
            VStack(spacing: 8) {
                Text("No Plants Yet").font(.title2.weight(.semibold)).foregroundColor(.primary)
                Text("Add your first plant and\nstart tracking its growth").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            }
            Button { showAddPlant = true } label: {
                HStack { Image(systemName: "plus.circle.fill"); Text("Add Plant") }.font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.leafGreen).clipShape(RoundedRectangle(cornerRadius: 12))
            }.padding(.horizontal, 40)
            Spacer(); Spacer()
        }.padding()
    }
    
    private var plantsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                filterChips.padding(.horizontal)
                statsCard.padding(.horizontal)
                ForEach(filteredPlants) { plant in
                    NavigationLink(destination: PlantDetailView(plant: plant, dataManager: dataManager)) {
                        PlantCardView(plant: plant)
                    }.buttonStyle(.plain).padding(.horizontal)
                }
            }.padding(.vertical)
        }
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedFilter == nil) { withAnimation { selectedFilter = nil } }
                ForEach(PlantType.allCases, id: \.self) { type in
                    let count = dataManager.plants.filter { $0.type == type }.count
                    if count > 0 {
                        FilterChip(title: "\(type.icon) \(type.rawValue)", isSelected: selectedFilter == type) { withAnimation { selectedFilter = type } }
                    }
                }
            }
        }
    }
    
    private var statsCard: some View {
        HStack(spacing: 0) {
            StatItem(icon: "leaf.fill", value: "\(dataManager.totalPlants)", label: "Plants", color: .leafGreen)
            Divider().frame(height: 40)
            StatItem(icon: "drop.fill", value: "\(dataManager.totalWaterings)", label: "Waterings", color: .waterColor)
            Divider().frame(height: 40)
            StatItem(icon: "camera.fill", value: "\(dataManager.totalPhotos)", label: "Photos", color: .photoColor)
        }
        .padding(.vertical, 12).background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

struct FilterChip: View {
    let title: String, isSelected: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.subheadline.weight(.medium)).foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14).padding(.vertical, 8).background(isSelected ? Color.leafGreen : Color(.systemBackground))
                .clipShape(Capsule()).shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

struct StatItem: View {
    let icon: String, value: String, label: String, color: Color
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) { Image(systemName: icon).font(.caption).foregroundColor(color); Text(value).font(.headline).foregroundColor(.primary) }
            Text(label).font(.caption2).foregroundColor(.secondary)
        }.frame(maxWidth: .infinity)
    }
}

#Preview { PlantListView(dataManager: DataManager.shared) }
