import SwiftUI

struct PlantCardView: View {
    let plant: Plant
    @State private var coverImage: UIImage?
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let image = coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color.leafGreen.opacity(0.2)
                        Text(plant.type.icon)
                            .font(.system(size: 36))
                    }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(plant.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: plant.currentPhase.icon)
                            .font(.caption)
                        Text(plant.currentPhase.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.phaseColor(for: plant.currentPhase))
                    .clipShape(Capsule())
                }
                
                Text(plant.displayType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    if let height = plant.currentHeight {
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .font(.caption2)
                            Text("\(height.heightFormatted) cm")
                                .font(.caption)
                        }
                        .foregroundColor(.warmBrown)
                    }
                    
                    if let lastWatering = plant.lastWatering {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.caption2)
                            Text(lastWatering.relativeDescription)
                                .font(.caption)
                        }
                        .foregroundColor(.waterColor)
                    }
                    
                    Spacer()
                    
                    Text("\(plant.daysSincePlanting) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            if let filename = plant.coverPhotoFilename {
                coverImage = PhotoManager.shared.loadPhoto(filename: filename)
            }
        }
    }
}

struct PlantCardCompact: View {
    let plant: Plant
    @State private var coverImage: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            Group {
                if let image = coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color.leafGreen.opacity(0.2)
                        Text(plant.type.icon)
                            .font(.system(size: 32))
                    }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(plant.name)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(plant.currentPhase.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 110)
        .onAppear {
            if let filename = plant.coverPhotoFilename {
                coverImage = PhotoManager.shared.loadPhoto(filename: filename)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PlantCardView(plant: Plant(
            name: "Cherry Tomato",
            type: .tomato,
            currentPhase: .blooming,
            growthRecords: [GrowthRecord(height: 45)],
            careRecords: [CareRecord(type: .watering)]
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
