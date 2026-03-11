import SwiftUI
import Charts

struct MoodData: Identifiable {
    let id = UUID()
    let mood: String
    let count: Int
}

struct MoodAnalyticsView: View {
    @ObservedObject var vm: DiaryViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    var moodData: [MoodData] {
        var counts: [String: Int] = [:]
        for entry in vm.entries {
            let mood = entry.mood ?? "📓"
            counts[mood, default: 0] += 1
        }
        return counts.map { MoodData(mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Mood Analytics")
            
            if moodData.isEmpty {
                Text("No mood data yet.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .frame(height: 120)
            } else {
                Chart(moodData) { data in
                    BarMark(
                        x: .value("Count", data.count),
                        y: .value("Mood", data.mood)
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [.accentPrimary, .accentSecondary],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text("\(data.count)")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let mood = value.as(String.self) {
                                Text(mood)
                                    .font(.system(size: 20)) // Show emoji larger
                            }
                        }
                    }
                }
                .frame(height: max(120, CGFloat(moodData.count * 40)))
            }
        }
        .cardStyle()
    }
}
