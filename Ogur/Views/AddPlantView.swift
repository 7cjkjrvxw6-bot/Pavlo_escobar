import SwiftUI

struct AddPlantView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedType: PlantType = .tomato
    @State private var customType = ""
    @State private var plantedDate = Date()
    @State private var currentPhase: PlantPhase = .seed
    @State private var selectedImage: UIImage?
    @State private var notes = ""
    @State private var showPhotoPicker = false
    @State private var showValidationError = false
    
    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) { photoSection; mainInfoSection; typeSection; datePhaseSection; notesSection; saveButton }.padding()
                }
            }
            .navigationTitle("New Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .sheet(isPresented: $showPhotoPicker) { PhotoSourcePicker(selectedImage: $selectedImage, isPresented: $showPhotoPicker).presentationDetents([.height(200)]) }
            .alert("Enter Name", isPresented: $showValidationError) { Button("OK", role: .cancel) {} } message: { Text("Plant name is required") }
        }
    }
    
    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill).frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 16))
                    Button { selectedImage = nil } label: { Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.white).shadow(radius: 4) }.padding(8)
                }
            } else {
                Button { showPhotoPicker = true } label: {
                    VStack(spacing: 12) {
                        ZStack { Circle().fill(Color.leafGreen.opacity(0.15)).frame(width: 80, height: 80); Image(systemName: "camera.fill").font(.title).foregroundColor(.leafGreen) }
                        Text("Add Photo").font(.subheadline).foregroundColor(.leafGreen)
                    }.frame(maxWidth: .infinity).frame(height: 160).background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    private var mainInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
            TextField("e.g. Cherry Tomato", text: $name).padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plant Type").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(PlantType.allCases, id: \.self) { type in TypeButton(type: type, isSelected: selectedType == type) { withAnimation { selectedType = type } } }
            }
            if selectedType == .other { TextField("Enter custom type", text: $customType).padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)) }
        }
    }
    
    private var datePhaseSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Planted Date").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
                DatePicker("", selection: $plantedDate, displayedComponents: .date).datePickerStyle(.compact).labelsHidden().padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Phase").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
                Menu {
                    ForEach(PlantPhase.allCases, id: \.self) { phase in Button { currentPhase = phase } label: { Label(phase.rawValue, systemImage: phase.icon) } }
                } label: {
                    HStack {
                        Image(systemName: currentPhase.icon).foregroundColor(Color.phaseColor(for: currentPhase))
                        Text(currentPhase.rawValue).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down").font(.caption).foregroundColor(.secondary)
                    }.padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
            TextField("Additional info...", text: $notes, axis: .vertical).lineLimit(3...6).padding().background(Color(.systemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var saveButton: some View {
        Button { savePlant() } label: {
            HStack { Image(systemName: "leaf.fill"); Text("Add Plant") }.font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.leafGreen).clipShape(RoundedRectangle(cornerRadius: 12))
        }.padding(.top, 8)
    }
    
    private func savePlant() {
        guard isValid else { showValidationError = true; return }
        var coverFilename: String?
        if let image = selectedImage {
            let plantId = UUID()
            coverFilename = PhotoManager.shared.savePhoto(image, for: plantId)
            var plant = Plant(id: plantId, name: name.trimmingCharacters(in: .whitespaces), type: selectedType, customType: selectedType == .other ? customType : nil, plantedDate: plantedDate, currentPhase: currentPhase, notes: notes.isEmpty ? nil : notes, coverPhotoFilename: coverFilename)
            if let filename = coverFilename { plant.photos.append(PhotoRecord(filename: filename)) }
            dataManager.addPlant(plant)
        } else {
            dataManager.addPlant(Plant(name: name.trimmingCharacters(in: .whitespaces), type: selectedType, customType: selectedType == .other ? customType : nil, plantedDate: plantedDate, currentPhase: currentPhase, notes: notes.isEmpty ? nil : notes))
        }
        dismiss()
    }
}

struct TypeButton: View {
    let type: PlantType, isSelected: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) { Text(type.icon).font(.title2); Text(type.rawValue).font(.caption2).foregroundColor(.primary).lineLimit(1) }
                .frame(maxWidth: .infinity).padding(.vertical, 12).background(isSelected ? Color.leafGreen.opacity(0.15) : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.leafGreen : Color.clear, lineWidth: 2))
        }
    }
}

#Preview { AddPlantView(dataManager: DataManager.shared) }
