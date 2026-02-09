import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    @MainActor static let shared = DataManager()
    
    @Published var plants: [Plant] = []
    @Published var reminders: [Reminder] = []
    
    private let plantsFileName = "plants.json"
    private let remindersFileName = "reminders.json"
    
    private init() {
        loadPlants()
        loadReminders()
    }
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var plantsFileURL: URL {
        documentsDirectory.appendingPathComponent(plantsFileName)
    }
    
    private var remindersFileURL: URL {
        documentsDirectory.appendingPathComponent(remindersFileName)
    }
    
    func loadPlants() {
        guard FileManager.default.fileExists(atPath: plantsFileURL.path) else {
            plants = []
            return
        }
        
        do {
            let data = try Data(contentsOf: plantsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            plants = try decoder.decode([Plant].self, from: data)
        } catch {
            print("Error loading plants: \(error)")
            plants = []
        }
    }
    
    func savePlants() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(plants)
            try data.write(to: plantsFileURL)
        } catch {
            print("Error saving plants: \(error)")
        }
    }
    
    func addPlant(_ plant: Plant) {
        var newPlant = plant
        let phaseChange = PhaseChangeRecord(toPhase: plant.currentPhase)
        newPlant.phaseChanges.append(phaseChange)
        plants.append(newPlant)
        savePlants()
    }
    
    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            savePlants()
        }
    }
    
    func deletePlant(_ plant: Plant) {
        PhotoManager.shared.deleteAllPhotos(for: plant)
        reminders.removeAll { $0.plantId == plant.id }
        saveReminders()
        plants.removeAll { $0.id == plant.id }
        savePlants()
    }
    
    func getPlant(by id: UUID) -> Plant? {
        plants.first { $0.id == id }
    }
    
    func addGrowthRecord(to plantId: UUID, height: Double) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        let record = GrowthRecord(height: height)
        plants[index].growthRecords.append(record)
        savePlants()
    }
    
    func addCareRecord(to plantId: UUID, type: CareType, note: String? = nil) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        let record = CareRecord(type: type, note: note)
        plants[index].careRecords.append(record)
        savePlants()
    }
    
    func addPhotoRecord(to plantId: UUID, filename: String, note: String? = nil) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        let record = PhotoRecord(filename: filename, note: note)
        plants[index].photos.append(record)
        
        if plants[index].coverPhotoFilename == nil {
            plants[index].coverPhotoFilename = filename
        }
        
        savePlants()
    }
    
    func deletePhotoRecord(from plantId: UUID, record: PhotoRecord) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        PhotoManager.shared.deletePhoto(filename: record.filename)
        plants[index].photos.removeAll { $0.id == record.id }
        
        if plants[index].coverPhotoFilename == record.filename {
            plants[index].coverPhotoFilename = plants[index].photos.first?.filename
        }
        
        savePlants()
    }
    
    func setCoverPhoto(for plantId: UUID, filename: String) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        plants[index].coverPhotoFilename = filename
        savePlants()
    }
    
    func changePhase(for plantId: UUID, to newPhase: PlantPhase) {
        guard let index = plants.firstIndex(where: { $0.id == plantId }) else { return }
        
        let currentPhase = plants[index].currentPhase
        guard currentPhase != newPhase else { return }
        
        let record = PhaseChangeRecord(fromPhase: currentPhase, toPhase: newPhase)
        plants[index].phaseChanges.append(record)
        plants[index].currentPhase = newPhase
        
        savePlants()
    }
    
    func loadReminders() {
        guard FileManager.default.fileExists(atPath: remindersFileURL.path) else {
            reminders = []
            return
        }
        
        do {
            let data = try Data(contentsOf: remindersFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            reminders = try decoder.decode([Reminder].self, from: data)
        } catch {
            print("Error loading reminders: \(error)")
            reminders = []
        }
    }
    
    func saveReminders() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(reminders)
            try data.write(to: remindersFileURL)
        } catch {
            print("Error saving reminders: \(error)")
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        let plantName = getPlant(by: reminder.plantId)?.name ?? "Plant"
        NotificationManager.shared.scheduleReminder(reminder, plantName: plantName)
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
            NotificationManager.shared.cancelReminder(reminder.id)
            if reminder.isEnabled {
                let plantName = getPlant(by: reminder.plantId)?.name ?? "Plant"
                NotificationManager.shared.scheduleReminder(reminder, plantName: plantName)
            }
        }
    }
    
    func deleteReminder(_ id: UUID) {
        NotificationManager.shared.cancelReminder(id)
        reminders.removeAll { $0.id == id }
        saveReminders()
    }
    
    func getReminders(for plantId: UUID) -> [Reminder] {
        reminders.filter { $0.plantId == plantId }
    }
    
    var totalPlants: Int { plants.count }
    
    var totalWaterings: Int {
        plants.reduce(0) { $0 + $1.careRecords.filter { $0.type == .watering }.count }
    }
    
    var totalFeedings: Int {
        plants.reduce(0) { $0 + $1.careRecords.filter { $0.type == .feeding }.count }
    }
    
    var totalPhotos: Int {
        plants.reduce(0) { $0 + $1.photos.count }
    }
    
    func getEventsForDate(_ date: Date) -> [TimelineEvent] {
        let calendar = Calendar.current
        var events: [TimelineEvent] = []
        
        for plant in plants {
            for record in plant.growthRecords where calendar.isDate(record.date, inSameDayAs: date) {
                events.append(TimelineEvent(date: record.date, type: .growth, title: "Growth: \(plant.name)", subtitle: "\(Int(record.height)) cm"))
            }
            for record in plant.careRecords where calendar.isDate(record.date, inSameDayAs: date) {
                let type: TimelineEventType = record.type == .watering ? .watering : .feeding
                events.append(TimelineEvent(date: record.date, type: type, title: "\(record.type.rawValue): \(plant.name)", subtitle: nil))
            }
            for record in plant.photos where calendar.isDate(record.date, inSameDayAs: date) {
                events.append(TimelineEvent(date: record.date, type: .photo, title: "Photo: \(plant.name)", subtitle: nil))
            }
            for record in plant.phaseChanges where calendar.isDate(record.date, inSameDayAs: date) {
                events.append(TimelineEvent(date: record.date, type: .phase, title: "Phase: \(plant.name)", subtitle: record.toPhase.rawValue))
            }
        }
        
        return events.sorted { $0.date > $1.date }
    }
    
    func hasEventsOnDate(_ date: Date) -> (watering: Bool, feeding: Bool, photo: Bool, phase: Bool) {
        let calendar = Calendar.current
        var result = (watering: false, feeding: false, photo: false, phase: false)
        
        for plant in plants {
            for record in plant.careRecords where calendar.isDate(record.date, inSameDayAs: date) {
                if record.type == .watering { result.watering = true }
                if record.type == .feeding { result.feeding = true }
            }
            for record in plant.photos where calendar.isDate(record.date, inSameDayAs: date) {
                result.photo = true
            }
            for record in plant.phaseChanges where calendar.isDate(record.date, inSameDayAs: date) {
                result.phase = true
            }
        }
        
        return result
    }
    
    func exportData() -> Data? {
        let exportData = ExportData(plants: plants, reminders: reminders, exportDate: Date())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(exportData)
    }
    
    func importData(from data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let importData = try decoder.decode(ExportData.self, from: data)
            plants = importData.plants
            reminders = importData.reminders
            savePlants()
            saveReminders()
            return true
        } catch {
            print("Import error: \(error)")
            return false
        }
    }
    
    func clearAllData() {
        for plant in plants {
            PhotoManager.shared.deleteAllPhotos(for: plant)
        }
        NotificationManager.shared.cancelAllReminders()
        plants = []
        reminders = []
        savePlants()
        saveReminders()
    }
}

struct ExportData: Codable {
    let plants: [Plant]
    let reminders: [Reminder]
    let exportDate: Date
}
