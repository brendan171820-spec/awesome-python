import WidgetKit
import SwiftUI

/// Dynamic AI-powered widget that updates based on user's theme
struct HomeScreenWidget: Widget {
    let kind = "HomeScreenAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThemeWidgetProvider()) { entry in
            ThemeWidgetView(entry: entry)
        }
        .configurationDisplayName("HomeScreen AI")
        .description("Dynamic widget matching your AI-generated theme")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ThemeEntry: TimelineEntry {
    let date: Date
    let primaryColor: Color
    let accentColor: Color
    let quote: String
    let greeting: String
}

struct ThemeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ThemeEntry {
        ThemeEntry(date: .now, primaryColor: .purple, accentColor: .pink,
                   quote: "Your home, your style.", greeting: "Good morning!")
    }

    func getSnapshot(in context: Context, completion: @escaping (ThemeEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThemeEntry>) -> Void) {
        let entry = loadCurrentThemeEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadCurrentThemeEntry() -> ThemeEntry {
        // Load saved theme from UserDefaults (App Group shared with main app)
        let defaults = UserDefaults(suiteName: "group.app.homescreenai")
        let primaryHex = defaults?.string(forKey: "primary_color") ?? "#7c3aed"
        let accentHex = defaults?.string(forKey: "accent_color") ?? "#ec4899"
        let greeting = greetingForCurrentHour()

        return ThemeEntry(
            date: .now,
            primaryColor: Color(hex: primaryHex),
            accentColor: Color(hex: accentHex),
            quote: "Your home, your style.",
            greeting: greeting
        )
    }

    private func greetingForCurrentHour() -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<12: return "Good morning! ☀️"
        case 12..<17: return "Good afternoon! 🌤"
        case 17..<21: return "Good evening! 🌆"
        default: return "Good night! 🌙"
        }
    }
}

struct ThemeWidgetView: View {
    let entry: ThemeEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [entry.primaryColor, entry.accentColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            switch family {
            case .systemSmall:
                smallWidget
            case .systemMedium:
                mediumWidget
            default:
                largeWidget
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var smallWidget: some View {
        VStack(alignment: .leading) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(entry.greeting)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(entry.greeting)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(entry.quote)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(16)
    }

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(entry.greeting)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(entry.quote)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
