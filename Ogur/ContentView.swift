import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlantListView(dataManager: dataManager)
                .tabItem {
                    Label("Plants", systemImage: "leaf.fill")
                }
                .tag(0)
            
            CalendarView(dataManager: dataManager)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            GardenView(dataManager: dataManager)
                .tabItem {
                    Label("Garden", systemImage: "house.fill")
                }
                .tag(2)
        }
        .tint(.leafGreen)
        .onAppear {
            NotificationManager.shared.clearBadge()
        }
    }
}

#Preview {
    ContentView()
}
