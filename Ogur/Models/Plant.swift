import Foundation

enum PlantPhase: String, Codable, CaseIterable {
    case seed = "Seed"
    case sprout = "Sprout"
    case growing = "Growing"
    case blooming = "Blooming"
    case fruiting = "Fruiting"
    case resting = "Resting"
    
    var icon: String {
        switch self {
        case .seed: return "leaf.fill"
        case .sprout: return "leaf.arrow.triangle.circlepath"
        case .growing: return "arrow.up.right"
        case .blooming: return "camera.macro"
        case .fruiting: return "carrot.fill"
        case .resting: return "moon.fill"
        }
    }
    
    var color: String {
        switch self {
        case .seed: return "seedColor"
        case .sprout: return "sproutColor"
        case .growing: return "growingColor"
        case .blooming: return "bloomingColor"
        case .fruiting: return "fruitingColor"
        case .resting: return "restingColor"
        }
    }
}

enum PlantType: String, Codable, CaseIterable {
    case tomato = "Tomato"
    case cucumber = "Cucumber"
    case seedling = "Seedling"
    case flower = "Flower"
    case herb = "Herb"
    case pepper = "Pepper"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .tomato: return "🍅"
        case .cucumber: return "🥒"
        case .seedling: return "🌱"
        case .flower: return "🌸"
        case .herb: return "🌿"
        case .pepper: return "🌶️"
        case .other: return "🪴"
        }
    }
}

struct GrowthRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let height: Double
    
    init(id: UUID = UUID(), date: Date = Date(), height: Double) {
        self.id = id
        self.date = date
        self.height = height
    }
}

enum CareType: String, Codable, CaseIterable {
    case watering = "Watering"
    case feeding = "Feeding"
    
    var icon: String {
        switch self {
        case .watering: return "drop.fill"
        case .feeding: return "leaf.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .watering: return "waterColor"
        case .feeding: return "feedingColor"
        }
    }
}

struct CareRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let type: CareType
    let date: Date
    var note: String?
    
    init(id: UUID = UUID(), type: CareType, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.note = note
    }
}

struct PhotoRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let filename: String
    var note: String?
    
    init(id: UUID = UUID(), date: Date = Date(), filename: String, note: String? = nil) {
        self.id = id
        self.date = date
        self.filename = filename
        self.note = note
    }
}

struct PhaseChangeRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let fromPhase: PlantPhase?
    let toPhase: PlantPhase
    
    init(id: UUID = UUID(), date: Date = Date(), fromPhase: PlantPhase? = nil, toPhase: PlantPhase) {
        self.id = id
        self.date = date
        self.fromPhase = fromPhase
        self.toPhase = toPhase
    }
}

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: PlantType
    var customType: String?
    var plantedDate: Date
    var currentPhase: PlantPhase
    var growthRecords: [GrowthRecord]
    var careRecords: [CareRecord]
    var photos: [PhotoRecord]
    var phaseChanges: [PhaseChangeRecord]
    var notes: String?
    var coverPhotoFilename: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: PlantType,
        customType: String? = nil,
        plantedDate: Date = Date(),
        currentPhase: PlantPhase = .seed,
        growthRecords: [GrowthRecord] = [],
        careRecords: [CareRecord] = [],
        photos: [PhotoRecord] = [],
        phaseChanges: [PhaseChangeRecord] = [],
        notes: String? = nil,
        coverPhotoFilename: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.customType = customType
        self.plantedDate = plantedDate
        self.currentPhase = currentPhase
        self.growthRecords = growthRecords
        self.careRecords = careRecords
        self.photos = photos
        self.phaseChanges = phaseChanges
        self.notes = notes
        self.coverPhotoFilename = coverPhotoFilename
    }
    
    var lastWatering: Date? {
        careRecords
            .filter { $0.type == .watering }
            .sorted { $0.date > $1.date }
            .first?.date
    }
    
    var lastFeeding: Date? {
        careRecords
            .filter { $0.type == .feeding }
            .sorted { $0.date > $1.date }
            .first?.date
    }
    
    var currentHeight: Double? {
        growthRecords
            .sorted { $0.date > $1.date }
            .first?.height
    }
    
    var displayType: String {
        if type == .other, let custom = customType, !custom.isEmpty {
            return custom
        }
        return type.rawValue
    }
    
    var daysSincePlanting: Int {
        Calendar.current.dateComponents([.day], from: plantedDate, to: Date()).day ?? 0
    }
}

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var plantId: UUID
    var type: ReminderType
    var time: Date
    var isEnabled: Bool
    var repeatInterval: RepeatInterval
    
    init(
        id: UUID = UUID(),
        plantId: UUID,
        type: ReminderType,
        time: Date,
        isEnabled: Bool = true,
        repeatInterval: RepeatInterval = .daily
    ) {
        self.id = id
        self.plantId = plantId
        self.type = type
        self.time = time
        self.isEnabled = isEnabled
        self.repeatInterval = repeatInterval
    }
}

enum ReminderType: String, Codable, CaseIterable {
    case watering = "Watering"
    case feeding = "Feeding"
    case photo = "Take Photo"
    case measurement = "Measure Growth"
    
    var icon: String {
        switch self {
        case .watering: return "drop.fill"
        case .feeding: return "leaf.circle.fill"
        case .photo: return "camera.fill"
        case .measurement: return "ruler"
        }
    }
}

enum RepeatInterval: String, Codable, CaseIterable {
    case daily = "Daily"
    case everyTwoDays = "Every 2 Days"
    case everyThreeDays = "Every 3 Days"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    
    var days: Int {
        switch self {
        case .daily: return 1
        case .everyTwoDays: return 2
        case .everyThreeDays: return 3
        case .weekly: return 7
        case .biweekly: return 14
        }
    }
}

