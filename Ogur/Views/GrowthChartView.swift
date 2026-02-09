import SwiftUI
import Charts

struct GrowthChartView: View {
    let records: [GrowthRecord]
    
    var sortedRecords: [GrowthRecord] {
        records.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        if sortedRecords.isEmpty {
            emptyState
        } else {
            chart
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No growth data yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chart: some View {
        Chart {
            ForEach(sortedRecords) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Height", record.height)
                )
                .foregroundStyle(Color.leafGreen)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", record.date),
                    y: .value("Height", record.height)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.leafGreen.opacity(0.3), Color.leafGreen.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", record.date),
                    y: .value("Height", record.height)
                )
                .foregroundStyle(Color.leafGreen)
                .symbolSize(40)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let height = value.as(Double.self) {
                        Text("\(Int(height))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxisLabel("cm", position: .leading)
    }
}

struct GrowthStatsView: View {
    let records: [GrowthRecord]
    
    var sortedRecords: [GrowthRecord] {
        records.sorted { $0.date < $1.date }
    }
    
    var totalGrowth: Double {
        guard let first = sortedRecords.first?.height,
              let last = sortedRecords.last?.height else { return 0 }
        return last - first
    }
    
    var averageGrowthRate: Double {
        guard sortedRecords.count >= 2 else { return 0 }
        let daysBetween = Calendar.current.dateComponents([.day], from: sortedRecords.first!.date, to: sortedRecords.last!.date).day ?? 1
        return totalGrowth / Double(max(daysBetween, 1))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            GrowthStatItem(
                title: "Current",
                value: sortedRecords.last?.height.heightFormatted ?? "-",
                unit: "cm",
                icon: "ruler"
            )
            Divider().frame(height: 40)
            GrowthStatItem(
                title: "Growth",
                value: totalGrowth > 0 ? "+\(totalGrowth.heightFormatted)" : totalGrowth.heightFormatted,
                unit: "cm",
                icon: "arrow.up"
            )
            Divider().frame(height: 40)
            GrowthStatItem(
                title: "Rate",
                value: averageGrowthRate.heightFormatted,
                unit: "cm/day",
                icon: "chart.line.uptrend.xyaxis"
            )
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GrowthStatItem: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(.leafGreen)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        GrowthChartView(records: [
            GrowthRecord(date: Date().addingTimeInterval(-86400 * 7), height: 5),
            GrowthRecord(date: Date().addingTimeInterval(-86400 * 5), height: 8),
            GrowthRecord(date: Date().addingTimeInterval(-86400 * 3), height: 12),
            GrowthRecord(date: Date().addingTimeInterval(-86400 * 1), height: 15),
            GrowthRecord(date: Date(), height: 18)
        ])
        .frame(height: 200)
        .padding()
    }
}
