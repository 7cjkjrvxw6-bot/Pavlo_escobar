import SwiftUI

enum TimelineEventType {
    case watering, feeding, growth, photo, phase
    
    var icon: String {
        switch self { case .watering: return "drop.fill"; case .feeding: return "leaf.fill"; case .growth: return "ruler"; case .photo: return "camera.fill"; case .phase: return "arrow.triangle.2.circlepath" }
    }
    
    var color: Color {
        switch self { case .watering: return .waterColor; case .feeding: return .feedingColor; case .growth: return .warmBrown; case .photo: return .photoColor; case .phase: return .phaseColor }
    }
}

struct TimelineEvent: Identifiable {
    let id = UUID()
    let date: Date
    let type: TimelineEventType
    let title: String
    let subtitle: String?
}

struct TimelineItemView: View {
    let event: TimelineEvent
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(event.type.color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: event.type.icon).font(.subheadline).foregroundColor(event.type.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(event.title).font(.subheadline.weight(.medium)).foregroundColor(.primary)
                    if let subtitle = event.subtitle {
                        Text("• \(subtitle)").font(.subheadline).foregroundColor(.secondary)
                    }
                }
                Text(event.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        TimelineItemView(event: TimelineEvent(date: Date(), type: .watering, title: "Watered", subtitle: nil))
        TimelineItemView(event: TimelineEvent(date: Date(), type: .growth, title: "Measured", subtitle: "15 cm"))
        TimelineItemView(event: TimelineEvent(date: Date(), type: .phase, title: "Phase changed", subtitle: "Blooming"))
    }.padding()
}
