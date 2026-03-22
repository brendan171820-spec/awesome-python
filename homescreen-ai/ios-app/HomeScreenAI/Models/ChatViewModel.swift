import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var isReadyToGenerate = false
    @Published var themeColors: [Color] = [.purple, .indigo]
    @Published var generatedTheme: ThemePackage?

    private let apiService = APIService()
    private var messageCount = 0

    func startConversation() async {
        guard messages.isEmpty else { return }
        isLoading = true
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hi! I'm your personal home screen designer. ✨\n\nLet's create something beautiful for you. First question: What are your favorite colors, or describe a mood/atmosphere you love?"
        )
        messages.append(welcomeMessage)
        isLoading = false
    }

    func send(_ text: String) async {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        messageCount += 1
        isLoading = true

        do {
            let apiMessages = messages.map { ["role": $0.role.rawValue, "content": $0.content] }
            let response = try await apiService.streamChat(messages: apiMessages) { [weak self] chunk in
                Task { @MainActor in
                    self?.appendToLastAssistantMessage(chunk)
                }
            }
            isLoading = false

            // After 4+ exchanges, offer to generate
            if messageCount >= 4 {
                isReadyToGenerate = true
            }

            // Update preview colors based on conversation
            updatePreviewColors()
        } catch {
            isLoading = false
            messages.append(ChatMessage(
                role: .assistant,
                content: "Oops, something went wrong. Please try again."
            ))
        }
    }

    func generateTheme() async {
        isLoading = true
        isReadyToGenerate = false

        // Add a loading message
        messages.append(ChatMessage(
            role: .assistant,
            content: "Perfect! Creating your personalized theme... This will take about 30 seconds. 🎨"
        ))

        do {
            let apiMessages = messages.map { ["role": $0.role.rawValue, "content": $0.content] }
            let package = try await apiService.generateTheme(messages: apiMessages)
            generatedTheme = package
            isLoading = false

            messages.append(ChatMessage(
                role: .assistant,
                content: "Your theme is ready! Tap below to see the preview and apply it. 🚀"
            ))
        } catch {
            isLoading = false
            messages.append(ChatMessage(
                role: .assistant,
                content: "Generation failed. Please try again."
            ))
        }
    }

    private func appendToLastAssistantMessage(_ chunk: String) {
        if let lastIndex = messages.indices.last, messages[lastIndex].role == .assistant {
            messages[lastIndex].content += chunk
        } else {
            messages.append(ChatMessage(role: .assistant, content: chunk))
        }
    }

    private func updatePreviewColors() {
        // Simple heuristic: detect color keywords in conversation
        let text = messages.map(\.content).joined(separator: " ").lowercased()
        if text.contains("dark") || text.contains("noir") {
            themeColors = [Color(hex: "#1a1a2e"), Color(hex: "#16213e")]
        } else if text.contains("purple") || text.contains("violet") {
            themeColors = [Color(hex: "#7c3aed"), Color(hex: "#4f46e5")]
        } else if text.contains("pink") || text.contains("rose") {
            themeColors = [Color(hex: "#ec4899"), Color(hex: "#f43f5e")]
        } else if text.contains("nature") || text.contains("green") {
            themeColors = [Color(hex: "#059669"), Color(hex: "#0d9488")]
        } else if text.contains("ocean") || text.contains("blue") {
            themeColors = [Color(hex: "#0ea5e9"), Color(hex: "#6366f1")]
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    var role: MessageRole
    var content: String
}

enum MessageRole: String {
    case user, assistant
}

struct ThemePackage {
    let profile: ThemeProfile
    let wallpaperData: Data
    let icons: [String: Data]
}

struct ThemeProfile: Codable {
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let aesthetic: String
    let mood: String
    let iconStyle: String
    let wallpaperPrompt: String
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
