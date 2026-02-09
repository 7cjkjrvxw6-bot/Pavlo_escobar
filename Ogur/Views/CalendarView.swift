import SwiftUI

struct CalendarView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) { legendCard; calendarCard; eventsCard }.padding()
                }
            }
            .navigationTitle("Care Calendar 📅")
        }
    }
    
    private var legendCard: some View {
        HStack(spacing: 16) {
            LegendItem(color: .waterColor, label: "Water")
            LegendItem(color: .feedingColor, label: "Feed")
            LegendItem(color: .photoColor, label: "Photo")
            LegendItem(color: .phaseColor, label: "Phase")
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button { withAnimation { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth } } label: { Image(systemName: "chevron.left").font(.title3).foregroundColor(.leafGreen) }
                Spacer()
                Text(monthYearString).font(.headline).foregroundColor(.primary)
                Spacer()
                Button { withAnimation { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth } } label: { Image(systemName: "chevron.right").font(.title3).foregroundColor(.leafGreen) }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysOfWeek, id: \.self) { day in Text(day).font(.caption2.weight(.medium)).foregroundColor(.secondary).frame(maxWidth: .infinity) }
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date { DayCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isToday: calendar.isDateInToday(date), events: dataManager.getEventsForDate(date)) { selectedDate = date } }
                    else { Color.clear.frame(height: 40) }
                }
            }
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var eventsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted)).font(.headline).foregroundColor(.primary)
            let events = dataManager.getEventsForDate(selectedDate)
            if events.isEmpty {
                HStack { Spacer(); VStack(spacing: 8) { Image(systemName: "calendar.badge.checkmark").font(.largeTitle).foregroundColor(.secondary); Text("No events").font(.subheadline).foregroundColor(.secondary) }; Spacer() }.padding(.vertical, 30)
            } else {
                ForEach(events) { event in TimelineItemView(event: event) }
            }
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        let firstWeekday = calendar.component(.weekday, from: start)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range { if let date = calendar.date(byAdding: .day, value: day - 1, to: start) { days.append(date) } }
        return days
    }
}

struct DayCell: View {
    let date: Date, isSelected: Bool, isToday: Bool, events: [TimelineEvent], onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))").font(.subheadline.weight(isSelected ? .bold : .regular)).foregroundColor(isSelected ? .white : (isToday ? .leafGreen : .primary))
                HStack(spacing: 2) {
                    if events.contains(where: { $0.type == .watering }) { Circle().fill(Color.waterColor).frame(width: 4, height: 4) }
                    if events.contains(where: { $0.type == .feeding }) { Circle().fill(Color.feedingColor).frame(width: 4, height: 4) }
                    if events.contains(where: { $0.type == .photo }) { Circle().fill(Color.photoColor).frame(width: 4, height: 4) }
                    if events.contains(where: { $0.type == .phase }) { Circle().fill(Color.phaseColor).frame(width: 4, height: 4) }
                }
            }
            .frame(maxWidth: .infinity).frame(height: 40).background(isSelected ? Color.leafGreen : Color.clear).clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct LegendItem: View {
    let color: Color, label: String
    var body: some View { HStack(spacing: 4) { Circle().fill(color).frame(width: 8, height: 8); Text(label).font(.caption2).foregroundColor(.secondary) } }
}

#Preview { CalendarView(dataManager: DataManager.shared) }
