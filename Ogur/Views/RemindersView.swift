import SwiftUI

struct RemindersView: View {
    let plant: Plant
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showAddReminder = false
    
    var reminders: [Reminder] { dataManager.getReminders(for: plant.id) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                if reminders.isEmpty { emptyState } else { remindersList }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button { showAddReminder = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(.leafGreen) } }
            }
            .sheet(isPresented: $showAddReminder) { AddReminderView(plant: plant, dataManager: dataManager) }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash").font(.system(size: 60)).foregroundColor(.secondary)
            Text("No Reminders").font(.title3.weight(.semibold)).foregroundColor(.primary)
            Text("Add reminders to stay on top of plant care").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            Button { showAddReminder = true } label: {
                HStack { Image(systemName: "plus.circle.fill"); Text("Add Reminder") }.font(.headline).foregroundColor(.white).padding(.horizontal, 24).padding(.vertical, 12).background(Color.leafGreen).clipShape(Capsule())
            }
        }.padding()
    }
    
    private var remindersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(reminders) { reminder in ReminderCard(reminder: reminder, onToggle: { toggleReminder(reminder) }, onDelete: { deleteReminder(reminder) }) }
            }.padding()
        }
    }
    
    private func toggleReminder(_ reminder: Reminder) {
        var updated = reminder; updated.isEnabled.toggle(); dataManager.updateReminder(updated)
        if updated.isEnabled { NotificationManager.shared.scheduleReminder(updated, plantName: plant.name) } else { NotificationManager.shared.cancelReminder(updated.id) }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        NotificationManager.shared.cancelReminder(reminder.id); dataManager.deleteReminder(reminder.id)
    }
}

struct ReminderCard: View {
    let reminder: Reminder, onToggle: () -> Void, onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.type.icon).font(.title2).foregroundColor(reminder.type.color).frame(width: 44, height: 44).background(reminder.type.color.opacity(0.15)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.type.rawValue).font(.headline).foregroundColor(.primary)
                HStack(spacing: 8) {
                    HStack(spacing: 4) { Image(systemName: "clock").font(.caption2); Text(reminder.time.formatted(date: .omitted, time: .shortened)) }
                    HStack(spacing: 4) { Image(systemName: "repeat").font(.caption2); Text("Every \(reminder.repeatInterval.rawValue)") }
                }.font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: .init(get: { reminder.isEnabled }, set: { _ in onToggle() })).labelsHidden()
        }
        .padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        .contextMenu { Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") } }
    }
}

struct AddReminderView: View {
    let plant: Plant
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: ReminderType = .watering
    @State private var selectedTime = Date()
    @State private var selectedFrequency: RepeatInterval = .daily
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reminder Type").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
                    ForEach(ReminderType.allCases, id: \.self) { type in
                        Button { selectedType = type } label: {
                            HStack {
                                Image(systemName: type.icon).foregroundColor(type.color).frame(width: 30)
                                Text(type.rawValue).foregroundColor(.primary)
                                Spacer()
                                if selectedType == type { Image(systemName: "checkmark.circle.fill").foregroundColor(.leafGreen) }
                            }.padding().background(selectedType == type ? Color.leafGreen.opacity(0.1) : Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute).datePickerStyle(.wheel).labelsHidden()
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(RepeatInterval.allCases, id: \.self) { freq in
                            Button { selectedFrequency = freq } label: {
                                Text(freq.rawValue).font(.subheadline.weight(.medium)).foregroundColor(selectedFrequency == freq ? .white : .primary)
                                    .padding(.horizontal, 16).padding(.vertical, 10).background(selectedFrequency == freq ? Color.leafGreen : Color(.systemBackground)).clipShape(Capsule())
                            }
                        }
                    }
                }
                Spacer()
                Button { saveReminder() } label: {
                    Text("Save Reminder").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.leafGreen).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }.padding().background(Color(.systemGroupedBackground)).navigationTitle("New Reminder").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Cancel") { dismiss() } } }
        }
    }
    
    private func saveReminder() {
        let reminder = Reminder(plantId: plant.id, type: selectedType, time: selectedTime, repeatInterval: selectedFrequency)
        dataManager.addReminder(reminder)
        NotificationManager.shared.scheduleReminder(reminder, plantName: plant.name)
        dismiss()
    }
}

extension ReminderType {
    var color: Color {
        switch self { case .watering: return .waterColor; case .feeding: return .feedingColor; case .photo: return .photoColor; case .measurement: return .warmBrown }
    }
}

#Preview { RemindersView(plant: Plant(name: "Tomato", type: .tomato, currentPhase: .growing), dataManager: DataManager.shared) }
