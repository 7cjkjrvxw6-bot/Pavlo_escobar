import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showWaterAlert = false
    @State private var showFeedAlert = false
    @State private var showGrowthSheet = false
    @State private var showPhotoSheet = false
    @State private var showPhaseSheet = false
    @State private var showReminders = false
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var selectedImage: UIImage?
    @State private var newHeight: String = ""
    @State private var selectedPhase: PlantPhase = .seed
    
    var currentPlant: Plant { dataManager.plants.first { $0.id == plant.id } ?? plant }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    actionButtons
                    growthSection
                    photosSection
                    timelineSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEditSheet = true } label: { Label("Edit", systemImage: "pencil") }
                    Button(role: .destructive) { showDeleteAlert = true } label: { Label("Delete", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle").foregroundColor(.leafGreen)
                }
            }
        }
        .alert("Mark Watering?", isPresented: $showWaterAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") { dataManager.addCareRecord(to: plant.id, type: .watering) }
        } message: { Text("Record watering for \(currentPlant.name)") }
        .alert("Mark Feeding?", isPresented: $showFeedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") { dataManager.addCareRecord(to: plant.id, type: .feeding) }
        } message: { Text("Record feeding for \(currentPlant.name)") }
        .alert("Delete Plant?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { dataManager.deletePlant(currentPlant); dismiss() }
        } message: { Text("This action cannot be undone") }
        .sheet(isPresented: $showGrowthSheet) { growthSheet }
        .sheet(isPresented: $showPhotoSheet) { PhotoSourcePicker(selectedImage: $selectedImage, isPresented: $showPhotoSheet).presentationDetents([.height(200)]) }
        .sheet(isPresented: $showPhaseSheet) { phaseSheet }
        .sheet(isPresented: $showReminders) { RemindersView(plant: currentPlant, dataManager: dataManager) }
        .sheet(isPresented: $showEditSheet) { EditPlantView(plant: currentPlant, dataManager: dataManager) }
        .onChange(of: selectedImage) { _, newImage in if let image = newImage { savePhoto(image) } }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Group {
                    if let filename = currentPlant.coverPhotoFilename, let image = PhotoManager.shared.loadPhoto(filename: filename) {
                        Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color.leafGreen.opacity(0.2)
                            Text(currentPlant.type.icon).font(.system(size: 40))
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentPlant.name).font(.title2.weight(.bold)).foregroundColor(.primary)
                    Text(currentPlant.displayType).font(.subheadline).foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: currentPlant.currentPhase.icon).font(.caption)
                        Text(currentPlant.currentPhase.rawValue).font(.caption.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.phaseColor(for: currentPlant.currentPhase))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            HStack(spacing: 0) {
                InfoItem(icon: "calendar", value: currentPlant.plantedDate.formatted(date: .abbreviated, time: .omitted), label: "Planted")
                Divider().frame(height: 40)
                InfoItem(icon: "clock", value: "\(currentPlant.daysSincePlanting) days", label: "Age")
                if let h = currentPlant.currentHeight {
                    Divider().frame(height: 40)
                    InfoItem(icon: "ruler", value: "\(h.heightFormatted) cm", label: "Height")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ActionButton(title: "Water", icon: "drop.fill", color: .waterColor) { showWaterAlert = true }
                ActionButton(title: "Feed", icon: "leaf.fill", color: .feedingColor) { showFeedAlert = true }
            }
            HStack(spacing: 12) {
                ActionButton(title: "Photo", icon: "camera.fill", color: .photoColor) { showPhotoSheet = true }
                ActionButton(title: "Measure", icon: "ruler", color: .warmBrown) { showGrowthSheet = true }
            }
            HStack(spacing: 12) {
                ActionButton(title: "Phase", icon: "arrow.triangle.2.circlepath", color: .phaseColor) { selectedPhase = currentPlant.currentPhase; showPhaseSheet = true }
                ActionButton(title: "Reminders", icon: "bell.fill", color: .orange) { showReminders = true }
            }
        }
    }
    
    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Growth Chart").font(.headline).foregroundColor(.primary)
                Spacer()
            }
            if currentPlant.growthRecords.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis").font(.largeTitle).foregroundColor(.secondary)
                        Text("No measurements yet").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
            } else {
                GrowthChartView(records: currentPlant.growthRecords).frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos").font(.headline).foregroundColor(.primary)
                Spacer()
                Text("\(currentPlant.photos.count)").font(.subheadline).foregroundColor(.secondary)
            }
            if currentPlant.photos.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "camera").font(.largeTitle).foregroundColor(.secondary)
                        Text("No photos yet").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
            } else {
                PhotoGridView(
                    photos: currentPlant.photos.sorted { $0.date > $1.date },
                    onTap: { _ in },
                    onDelete: { photo in dataManager.deletePhotoRecord(from: plant.id, record: photo) }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline").font(.headline).foregroundColor(.primary)
            let events = getTimelineEvents()
            if events.isEmpty {
                HStack {
                    Spacer()
                    Text("No activity yet").font(.subheadline).foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(events.prefix(10)) { event in
                    TimelineItemView(event: event)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private var growthSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📏").font(.system(size: 60))
                Text("Measure Height").font(.title2.weight(.bold)).foregroundColor(.primary)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height (cm)").font(.subheadline).foregroundColor(.secondary)
                    TextField("e.g. 15.5", text: $newHeight)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
                Button {
                    if let h = Double(newHeight.replacingOccurrences(of: ",", with: ".")), h > 0 {
                        dataManager.addGrowthRecord(to: plant.id, height: h)
                        newHeight = ""
                        showGrowthSheet = false
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.leafGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(Double(newHeight.replacingOccurrences(of: ",", with: ".")) == nil)
            }
            .padding()
            .navigationTitle("New Measurement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showGrowthSheet = false }
                }
            }
        }
        .presentationDetents([.height(350)])
    }
    
    private var phaseSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🔄").font(.system(size: 60))
                Text("Change Phase").font(.title2.weight(.bold)).foregroundColor(.primary)
                VStack(spacing: 10) {
                    ForEach(PlantPhase.allCases, id: \.self) { phase in
                        Button { selectedPhase = phase } label: {
                            HStack {
                                Image(systemName: phase.icon)
                                    .foregroundColor(Color.phaseColor(for: phase))
                                    .frame(width: 30)
                                Text(phase.rawValue).foregroundColor(.primary)
                                Spacer()
                                if selectedPhase == phase {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.leafGreen)
                                }
                            }
                            .padding()
                            .background(selectedPhase == phase ? Color.leafGreen.opacity(0.1) : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                Spacer()
                Button {
                    dataManager.changePhase(for: plant.id, to: selectedPhase)
                    showPhaseSheet = false
                } label: {
                    Text("Update Phase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.leafGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationTitle("Plant Phase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showPhaseSheet = false }
                }
            }
        }
        .presentationDetents([.height(500)])
    }
    
    private func savePhoto(_ image: UIImage) {
        if let filename = PhotoManager.shared.savePhoto(image, for: plant.id) {
            dataManager.addPhotoRecord(to: plant.id, filename: filename)
        }
        selectedImage = nil
    }
    
    private func getTimelineEvents() -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        for record in currentPlant.careRecords {
            events.append(TimelineEvent(
                date: record.date,
                type: record.type == .watering ? .watering : .feeding,
                title: record.type == .watering ? "Watered" : "Fed",
                subtitle: nil
            ))
        }
        for record in currentPlant.growthRecords {
            events.append(TimelineEvent(
                date: record.date,
                type: .growth,
                title: "Measured",
                subtitle: "\(record.height.heightFormatted) cm"
            ))
        }
        for record in currentPlant.photos {
            events.append(TimelineEvent(
                date: record.date,
                type: .photo,
                title: "Photo added",
                subtitle: nil
            ))
        }
        for record in currentPlant.phaseChanges {
            events.append(TimelineEvent(
                date: record.date,
                type: .phase,
                title: "Phase changed",
                subtitle: record.toPhase.rawValue
            ))
        }
        return events.sorted { $0.date > $1.date }
    }
}

struct InfoItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2).foregroundColor(.leafGreen)
                Text(value).font(.subheadline.weight(.medium)).foregroundColor(.primary)
            }
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

struct EditPlantView: View {
    let plant: Plant
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name").font(.subheadline).foregroundColor(.secondary)
                    TextField("Plant name", text: $name)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.subheadline).foregroundColor(.secondary)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
                Button {
                    var updated = plant
                    updated.name = name
                    updated.notes = notes.isEmpty ? nil : notes
                    dataManager.updatePlant(updated)
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.leafGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = plant.name
                notes = plant.notes ?? ""
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(name: "Tomato", type: .tomato, currentPhase: .blooming), dataManager: DataManager.shared)
    }
}
